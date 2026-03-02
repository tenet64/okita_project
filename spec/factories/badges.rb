FactoryBot.define do
  factory :badge do
    name { "テストバッジ" }
    description { "テスト用のバッジです" }
    image_path { "badges/test.png" }
    # 複数作っても被らないように sequence を使う
    sequence(:condition_key) { |n| "test_condition_#{n}" }
  end
end
