class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    today = Date.current

    # ① 今日のチャレンジ（自分が関係しているもの）
    @today_challenges = Challenge
    .left_joins(:participations)
    .where(target_date: today)
    .where(status: %i[recruiting ready])
    .where(
      "challenges.user_id = :user_id OR participations.user_id = :user_id",
      user_id: current_user.id
    )
    .distinct

    # ② 参加中の未来チャレンジ
    @upcoming_challenges = Challenge
      .left_joins(:participations)
      .where("target_date > ?", today)
      .where(status: %i[recruiting ready])
      .where(
        "challenges.user_id = :user_id OR participations.user_id = :user_id",
        user_id: current_user.id
      )
      .distinct
      .order(:target_date, :target_time)

    def refresh_challenge_statuses!
      (@today_challenges + @upcoming_challenges).each do |c|
      c.refresh_status_by_logs!(date: c.target_date)
      end
    end
  end
end
