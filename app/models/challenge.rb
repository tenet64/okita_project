class Challenge < ApplicationRecord
  enum :mode, { solo: 1, multi: 2 }
  enum :status, {
    recruiting: 0,
    ready: 1,
    success: 2,
    failed: 3
  }

  belongs_to :user
  has_many :participations, dependent: :destroy
  has_many :participants, through: :participations, source: :user
  has_many :wake_up_logs, dependent: :destroy

  validates :title, presence: true
  validates :target_date, presence: true
  validates :target_time, presence: true
  validate :target_datetime_cannot_be_in_the_past

  validates :capacity, presence: true, if: :multi?
  validates :capacity,
            numericality: { only_integer: true, greater_than_or_equal_to: 2 },
            if: :multi?,
            allow_nil: true

  # ソロでは定員を持たない（誤入力防止）
  validates :capacity, absence: true, if: :solo?

  before_validation :clear_capacity_for_solo

  # 目標日時（Time）を返す
  def target_at
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
    td = target_at
    td&.advance(minutes: -5)
  end

  def wakeup_window_end
    td = target_at
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
      # 募集中でも「起床までの残り時間（カウントダウン）」は表示したい。
      # ただし詳細表示は、ホスト or 参加者 or 参加可能ユーザーに限定する。
      show_countdown = host?(user) || participant?(user) || can_participate?(user)
      return :recruiting_waiting if show_countdown && target_at.present? && Time.current < target_at
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

  # ソロ: ホストのみ / マルチ: ホスト + 参加者
  def members
    return [ user ] if solo?

    ([ user ] + participants.to_a).uniq
  end

  # 削除は起床時刻の60分前まで
  def destroyable?
    ta = target_at
    return false if ta.blank?

    Time.zone.now < ta - 60.minutes
  end

  # 判定締切（起床時刻 + 猶予）。MVP は 5分猶予。
  def judge_deadline_at
    ta = target_at
    return nil if ta.blank?

    ta + 5.minutes
  end

  # 起床ログを元にチャレンジ全体の状態を更新する
  # - 期限前: 全員成功なら success（途中は ready のまま）
  # - 期限後: 押していないメンバーに failure ログを自動作成し、failed を確定
  def refresh_status_by_logs!(date: target_date)
    return if date.blank?
    return if success? || failed?
    return unless ready?

    member_ids = members.map(&:id)

    # 先に「全員成功なら success」を確定（期限前でもOK）
    success_user_ids =
      wake_up_logs
        .where(user_id: member_ids, target_date: date, status: :success)
        .distinct
        .pluck(:user_id)

    if (member_ids - success_user_ids).empty?
      update!(status: :success)
      return
    end

    # 期限前はここで終了（失敗確定はしない）
    deadline = judge_deadline_at
    return if deadline.blank? || Time.zone.now < deadline

    # 期限後: 押していないメンバーに failure ログを作って failed を確定
    missing_ids = member_ids - success_user_ids

    ApplicationRecord.transaction do
      missing_ids.each do |uid|
        WakeUpLog.find_or_create_by!(user_id: uid, challenge_id: id, target_date: date) do |log|
          log.status = :failure
          log.pressed_at = nil
        end
      rescue ActiveRecord::RecordNotUnique
        # 競合したら無視
      end

      update!(status: :failed)
    end
  end

  def finalize_recruiting_if_due!
  return unless recruiting?
  return unless multi?
  return if target_at.blank?
  return if Time.current < target_at

  if capacity.present? && participations.count >= capacity
    update!(status: :ready)
  else
    update!(status: :failed) # 募集不成立を failed 扱い（MVP）
  end
end

  private

  def target_datetime_cannot_be_in_the_past
    return if target_at.blank?

    # 新規作成時、または起床日/起床時間を変更したときだけチェックする
    return unless new_record? || will_save_change_to_target_date? || will_save_change_to_target_time?

    if target_at < Time.zone.now
      errors.add(:target_time, "は現在時刻より後を選択してください")
    end
  end

  def clear_capacity_for_solo
    self.capacity = nil if solo?
  end
end
