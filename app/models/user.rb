class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates :name, presence: true
  has_many :challenges, dependent: :destroy
  has_many :wake_up_logs, dependent: :destroy
  has_many :point_transactions, dependent: :destroy
  has_many :participations, dependent: :destroy
  has_many :user_badges, dependent: :destroy
  has_many :badges, through: :user_badges
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # ① 現在のストリーク（連続成功日数）を計算
  def current_streak
    # 過去120日分のログを取得して日付ごとに成功判定
    recent_logs = wake_up_logs.where(pressed_at: 120.days.ago.beginning_of_day..Time.current)
    by_day = recent_logs.group_by { |l| l.pressed_at.to_date }
    daily_success = by_day.transform_values { |arr| arr.any?(&:success?) }

    streak = 0
    today = Date.current

    # 今日から過去に遡って連続成功をカウント
    today.downto(today - 120) do |d|
      break unless daily_success[d]
      streak += 1
    end

    streak
  end

  # ② 今週の統計（挑戦回数、成功数、成功率）をまとめてハッシュで返す
  def weekly_stats
    week_start = Date.current.beginning_of_week(:monday)
    week_range = week_start.beginning_of_day..(week_start + 6).end_of_day

    # 今週のログ
    logs = wake_up_logs.where(pressed_at: week_range)

    attempts = logs.count
    successes = logs.to_a.count(&:success?)
    rate = attempts.zero? ? 0 : ((successes.fdiv(attempts)) * 100).round

    # 結果をハッシュで返す
    {
      attempts: attempts,
      successes: successes,
      rate: rate
    }
  end

  # ③ 直近7日間の平均起床時刻を計算（"HH:MM"形式で返す）
  def average_wake_up_time_last_7_days
    today = Date.current
    last7_range = (today - 6.days).beginning_of_day..today.end_of_day

    # 直近7日間のログを取得
    logs = wake_up_logs.where(pressed_at: last7_range).order(:pressed_at)
    by_day = logs.group_by { |l| l.pressed_at.to_date }

    # 日ごとの最初の時刻を秒数に変換してリスト化
    times_in_seconds = (today - 6..today).filter_map do |date|
      first_log = by_day[date]&.min_by(&:pressed_at)
      next unless first_log
      first_log.pressed_at.seconds_since_midnight
    end

    return nil if times_in_seconds.empty?

    # 平均を計算してフォーマット
    avg_seconds = (times_in_seconds.sum / times_in_seconds.size).round
    Time.zone.at(avg_seconds).utc.strftime("%H:%M")
  end

  # ④ 現在の合計ポイント
  def total_points
    point_transactions.sum(:points)
  end

  def award_badge!(condition_key)
    badge = Badge.find_by(condition_key: condition_key)
    return unless badge

    return if badges.exists?(id: badge.id)

    user_badges.create!(badge: badge)
  end

  def check_total_success_badges
    count = challenges.where(status: :success).count

    award_badge!("total_success_1")   if count >= 1
    award_badge!("total_success_10")  if count >= 10
    award_badge!("total_success_30")  if count >= 30
    award_badge!("total_success_100") if count >= 100
  end

  def check_solo_mode_badges
    count = challenges.where(mode: :solo, status: :success).count

    award_badge!("solo_success_10") if count >= 10
  end

  def check_multi_mode_badges
    count = challenges.where(mode: :multi, status: :success).count

    award_badge!("multi_success_1")  if count >= 1
    award_badge!("multi_success_10") if count >= 10
  end

  def check_all_badges
    check_total_success_badges
    check_solo_mode_badges
    check_multi_mode_badges
  end

  def wake_up_time_chart(start_date)
    end_date = start_date + 6.days
    logs = wake_up_logs.where(pressed_at: start_date.beginning_of_day..end_date.end_of_day)
    logs_by_date = logs.index_by { |log| log.pressed_at.to_date }

    (start_date..end_date).map do |date|
      log = logs_by_date[date]
      # X軸: 日付ラベル
      label = date.strftime("%-m/%-d")

      if log
        hours = log.pressed_at.hour + (log.pressed_at.min / 60.0)
        [ label, hours ]
      else
        [ label, nil ]
      end
    end
  end
end
