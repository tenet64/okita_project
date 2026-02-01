class MypagesController < ApplicationController
  before_action :authenticate_user!

  def show
    @wake_up_logs = current_user.wake_up_logs
      .includes(:challenge)
      .order(created_at: :desc)

    # --- MVP向けの統計情報（DBスキーマ変更なし） ---
    today = Date.current

    # ストリークや統計計算に使う期間を限定する
    recent_logs = current_user.wake_up_logs
      .where(pressed_at: 120.days.ago.beginning_of_day..Time.current)
      .order(:pressed_at)

    # pressed_at を基準に、ログを日付単位でまとめる
    by_day = recent_logs.group_by { |l| l.pressed_at.to_date }

    # その日に1件でも成功ログがあれば、その日は「成功」とみなす
    daily_success = by_day.transform_values { |arr| arr.any?(&:success?) }

    # その日の最初の押下時刻（平均起床時刻の算出用）
    daily_first_time = by_day.transform_values { |arr| arr.map(&:pressed_at).min }

    # 現在のストリーク：今日まで連続して成功している日数
    streak = 0
    today.downto(today - 120) do |d|
      break unless daily_success[d]
      streak += 1
    end
    @current_streak = streak

    # 直近120日間での最長ストリーク
    longest = 0
    run = 0
    ((today - 120)..today).each do |d|
      if daily_success[d]
        run += 1
        longest = [ longest, run ].max
      else
        run = 0
      end
    end
    @longest_streak = longest

    # 今週（月〜日）の成功率（挑戦回数を母数にする）
    week_start = today.beginning_of_week(:monday)
    week_range = week_start.beginning_of_day..(week_start + 6).end_of_day

    week_logs = current_user.wake_up_logs.where(pressed_at: week_range)

    week_attempts = week_logs.count
    week_successes = week_logs.to_a.count(&:success?)

    @attempts_week = week_attempts
    @successes_week = week_successes
    @success_rate_week = week_attempts.zero? ? 0 : ((week_successes.fdiv(week_attempts)) * 100).round

    last7 = (today - 6..today).to_a

    # 直近7日間の平均起床時刻（ログがある日の最初の押下のみ対象）
    times = last7.filter_map do |d|
      t = daily_first_time[d]
      next unless t
      t.seconds_since_midnight
    end

    if times.any?
      avg_seconds = (times.sum / times.size).round
      # 日付を除き、ローカル時刻の HH:MM 形式で表示
      @avg_wake_time_7d = Time.zone.at(avg_seconds).utc.strftime("%H:%M")
    else
      @avg_wake_time_7d = nil
    end

    # 現在のポイント（台帳の合計）
    @points = current_user.point_transactions.sum(:points)
  end
end
