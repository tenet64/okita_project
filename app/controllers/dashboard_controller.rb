class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    today = Date.current

    scope = Challenge
      .left_joins(:participations)
      .where(status: %i[recruiting ready])
      .where(
        "challenges.user_id = :user_id OR participations.user_id = :user_id",
        user_id: current_user.id
      )
      .distinct

    # ① 今日のチャレンジ（自分が関係しているもの）
    @today_challenges = scope.where(target_date: today)

    # ② 参加中の未来チャレンジ
    @upcoming_challenges = scope
      .where("target_date > ?", today)
      .order(:target_date, :target_time)

    refresh_challenge_status!
  end

  private

  def refresh_challenge_status!
    (@today_challenges + @upcoming_challenges).each do |challenge|
      challenge.refresh_status_by_logs!(date: challenge.target_date)
    end
  end
end
