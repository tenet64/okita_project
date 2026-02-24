badge_data_list = [
  # --- 起床成功回数 (Total Success) ---
  {
    name: "初めの一歩",
    description: "起床成功 累計 1回",
    image_path: "badges/first_step.png",
    condition_key: "total_success_1"
  },
  {
    name: "早起きビギナー",
    description: "起床成功 累計 10回",
    image_path: "badges/beginner.png",
    condition_key: "total_success_10"
  },
  {
    name: "早起き玄人",
    description: "起床成功 累計 30回",
    image_path: "badges/expert.png",
    condition_key: "total_success_30"
  },
  {
    name: "継続の神",
    description: "起床成功 累計 100回",
    image_path: "badges/god.png",
    condition_key: "total_success_100"
  },

  # --- ソロモード (Solo Mode) ---
  {
    name: "一匹狼",
    description: "ソロモード成功 累計 10回",
    image_path: "badges/wolf.png",
    condition_key: "solo_success_10"
  },

  # --- マルチモード (Multi Mode) ---
  {
    name: "チームプレイヤー",
    description: "マルチモードで 1回成功",
    image_path: "badges/team_player.png",
    condition_key: "πmulti_success_1"
  },
  {
    name: "友情の証",
    description: "マルチモード成功 累計 10回",
    image_path: "badges/friendship.png",
    condition_key: "multi_success_10"
  }
]

badge_data_list.each do |data|
  badge = Badge.find_or_initialize_by(condition_key: data[:condition_key])

  badge.name = data[:name]
  badge.description = data[:description]
  badge.image_path = data[:image_path]
  badge.save!
end

# db/seeds.rb

puts "🌱 データの作成を開始します..."

# 1. ユーザー作成
user = User.find_or_create_by!(email: "demo@example.com") do |u|
  u.name = "早起き 太郎"
  u.password = "password"
  u.password_confirmation = "password"
end

puts "👤 ユーザー: #{user.name}"

# 2. リセット（ログ→チャレンジの順に消す）
user.wake_up_logs.destroy_all
user.challenges.destroy_all

# 3. 過去21日分の「チャレンジ」を作成する
puts "📅 過去のチャレンジデータを作成中..."

(0..21).each do |i|
  target_date = 21.days.ago.to_date + i.days

  # ランダムに成功/失敗を決める
  is_success = [ true, false ].sample
  status = is_success ? :success : :failed

  # Challengeのインスタンスを作成（まだ保存しない）
  challenge = user.challenges.build(
    title: "早起きチャレンジ #{target_date.strftime('%m/%d')}",
    target_date: target_date,
    target_time: "06:30".to_time,
    mode: :solo,
    status: status
  )

  # 【重要】過去の日付だとバリデーションエラーになるので、
  # validate: false を指定して強制的に保存する！
  challenge.save!(validate: false)

  # 整合性を保つため、成功ならログも作っておく
  # （カレンダー表示には必須ではないが、詳細画面で矛盾しないように）
  if is_success
    WakeUpLog.create!(
      user: user,
      challenge: challenge,
      target_date: target_date,
      pressed_at: target_date.in_time_zone.change(hour: 6, min: rand(0..30)),
      status: :success
    )
  end

  puts "  #{is_success ? '☀️' : '☁️'} #{target_date} のチャレンジ作成"
end

# 4. 明日（未来）のチャレンジも1つ作っておく（これは通常通り保存）
future_challenge = user.challenges.create!(
  title: "明日の早起き",
  target_date: Date.tomorrow,
  target_time: "06:30".to_time,
  mode: :solo,
  status: :ready
)
puts "🚀 明日のチャレンジ作成: #{future_challenge.target_date}"

puts "🎉 データ作成完了！これでカレンダーにChallengeが表示されます！"
