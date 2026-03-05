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
    condition_key: "multi_success_1"
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
