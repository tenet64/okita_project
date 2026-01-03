class Challenge < ApplicationRecord
  enum mode: { solo: 1, multi: 2 }
  enum status: {
    recruiting: 0,
    ready: 1,
    success: 2,
    failed: 3
  }
  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :wake_up_logs, dependent: :destroy

  validates :title, presence: true
  validates :target_date, presence: true
  validates :target_time, presence: true

  validates :capacity, presence: true, if: :multi?
  validates :capacity,
            numericality: { only_integer: true, greater_than_or_equal_to: 2 },
            if: :multi?,
            allow_nil: true

  # ソロでは定員を持たない（誤入力防止）
  validates :capacity, absence: true, if: :solo?

  before_validation :clear_capacity_for_solo

  def target_datetime
    return nil if target_date.blank? || target_time.blank?
    Time.zone.local(
      target_date.year,
      target_date.month,
      target_date.day,
      target_time.hour,
      target_time.min,
      target_time.sec
    )
  end

  # 起床成功判定ウィンドウ（±5分）
  def wakeup_window_start
    td = target_datetime
    td&.advance(minutes: -5)
  end

  def wakeup_window_end
    td = target_datetime
    td&.advance(minutes: 5)
  end

  # 「起きた！」を押して成功判定できる時間帯（±5分の間）
  def wakeup_available?
    return false unless ready?
    ws = wakeup_window_start
    we = wakeup_window_end
    return false if ws.blank? || we.blank?
    Time.current.between?(ws, we)
  end

  # 起床ウィンドウ開始前（早すぎ）
  def waiting_for_wakeup?
    return false unless ready?
    ws = wakeup_window_start
    return false if ws.blank?
    Time.current < ws
  end

  # 起床ウィンドウ終了後（押しそびれ）
  def wakeup_missed?
    return false unless ready?
    we = wakeup_window_end
    return false if we.blank?
    Time.current > we
  end

  def capacity_available?
    return false if capacity.blank?
    participations.count < capacity
  end

  def wake_up_done?(user)
    return false if user.blank?
    wake_up_logs.exists?(user: user)
  end

  def host?(user)
    return false if user.blank?
    user_id == user.id
  end

  def participant?(user)
    return false if user.blank?
    participations.exists?(user: user)
  end

  def can_participate?(user)
    return false if user.blank?
    return false unless recruiting?
    return false unless multi?
    return false if host?(user) # ホストは作成時に自動参加させる前提
    return false if participant?(user)
    capacity_available?
  end

  def can_wake_up?(user)
    return false if user.blank?
    return false unless ready?
    return false unless wakeup_available?
    return false if wake_up_done?(user)

    if solo?
      host?(user)
    else
      participant?(user)
    end
  end

  # 画面（show）のアクションエリア用：今どの状態を表示すべきかを返す
  # View 側はこの戻り値だけで case 分岐すれば良い
  def action_state_for(user)
    return :success if success?
    return :failed if failed?

    if recruiting?
      return :recruiting_joined if host?(user) || participant?(user)
      return :recruiting_can_join if can_participate?(user)
      return :recruiting_full
    end

    if ready?
      # 権限がないユーザーには詳細（待機/カウントダウン）を見せない
      allowed =
        if solo?
          host?(user)
        else
          participant?(user) || host?(user)
        end

      return :ready_no_permission unless allowed

      return :ready_done if wake_up_done?(user)
      return :ready_waiting if waiting_for_wakeup?
      return :ready_missed if wakeup_missed?
      return :ready_can_wake if can_wake_up?(user)
      return :ready_no_permission
    end

    :unknown
  end

  private

  def clear_capacity_for_solo
    self.capacity = nil if solo?
  end
end
