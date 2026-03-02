FactoryBot.define do
  factory :challenge do
    association :user
    title { "テストチャレンジ" }
    target_date { 1.day.from_now.to_date }
    target_time { "06:30" }
    mode { :solo }
    status { :ready }

    # マルチモード用
    trait :multi do
      mode { :multi }
      capacity { 3 }
      status { :recruiting }
    end
  end
end
