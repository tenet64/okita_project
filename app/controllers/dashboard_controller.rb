class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    today = Date.current

    # ① 今日のチャレンジ（自分が関係しているもの）
    @today_challenges = Challenge
      .left_joins(:participations)
      .where(target_date: today)
      .where(
        "challenges.user_id = :user_id OR participations.user_id = :user_id",
        user_id: current_user.id
      )
      .distinct

    # ② 参加中の未来チャレンジ
    @upcoming_challenges = Challenge
      .left_joins(:participations)
      .where("target_date > ?", today)
      .where(
        "challenges.user_id = :user_id OR participations.user_id = :user_id",
        user_id: current_user.id
      )
      .distinct
      .order(:target_date, :target_time)

    # ③ 参加可能なマルチチャレンジ
    @open_challenges = Challenge
      .multi
      .where("target_date >= ?", today)
      .left_joins(:participations)
      .group("challenges.id")
      .having("COUNT(participations.id) < challenges.capacity")
      .where.not(
        id: Participation.where(user_id: current_user.id).select(:challenge_id)
      )
  end
end