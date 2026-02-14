class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @wake_up_logs = current_user.wake_up_logs
      .includes(:challenge)
      .order(created_at: :desc)
      .limit(50)

    # 1. ストリーク
    @current_streak = current_user.current_streak

    # 2. 今週の成績
    stats = current_user.weekly_stats
    @attempts_week  = stats[:attempts]
    @successes_week = stats[:successes]
    @success_rate_week = stats[:rate]

    # 3. 平均起床時刻
    @avg_wake_time_7d = current_user.average_wake_up_time_last_7_days

    # 4. 合計ポイント
    @points = current_user.total_points

    # 5. バッジ情報
    @badges = Badge.all.order(id: :asc)
    @my_badge_ids = current_user.badges.pluck(:id)
  end

  def calendar
    # 表示する月の開始日を取得（デフォルトは当日）
    start_date = params.fetch(:start_date, Date.today).to_date

    # その月のチャレンジデータを取得
    @challenges = current_user.challenges.where(target_date: start_date.all_month)
  end

  def graph
  end
end
