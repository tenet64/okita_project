class WakeUpLog < ApplicationRecord
  belongs_to :user
  belongs_to :challenge

  enum :status, { success: 0, failure: 1 }

  # 同一ユーザーが同一チャレンジ・同一日(target_date)に複数回記録できないようにする
  validates :user_id, uniqueness: { scope: [ :challenge_id, :target_date ] }

  # ログ作成後にポイント付与を試みる（成功ログのみ）
  after_commit :grant_points, on: :create
  after_commit :refresh_challenge_status, on: :create
  before_validation :set_target_date, on: :create

  private

  def grant_points
    return unless success?

    if challenge.solo?
      grant_solo_point
    elsif challenge.multi?
      try_grant_multi_points
    end
  end


  def set_target_date
    self.target_date ||= pressed_at&.to_date || Time.zone.today
  end

  # ソロ: 成功ログ1件につき1ポイント
  def grant_solo_point
    PointTransaction.create!(
      user: user,
      points: 1,
      reason: :solo_success,
      source: self,
      target_date: target_date
    )
  rescue ActiveRecord::RecordNotUnique
    # すでに付与済みなら何もしない
  end

  # マルチ: 全員が成功した場合のみ、全員に1ポイントを付与
  def try_grant_multi_points
    # Challenge#members が「ホスト + 参加者」を返す前提
    members = challenge.members
    all_member = members.size
    # メンバーが0ならここで終了
    return if all_member.zero?

    all_success = members.all? do |member|
      member.wake_up_logs.exists?(
        challenge_id: challenge.id,
        target_date: target_date,
        status: WakeUpLog.status[:success]
      )
    end
    # もし全員が成功（all_success）していなければ、ここで処理を終了する
    return unless all_success

    members.each do |member|
      PointTransaction.create!(
        user: member,
        points: 1,
        reason: :multi_success,
        source: challenge,
        target_date: target_date
      )
    rescue ActiveRecord::RecordNotUnique
      # すでに付与済みなら次へ
    end
  end

  def refresh_challenge_status
    challenge.refresh_status_by_logs!(date: target_date)
  end
end
