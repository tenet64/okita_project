FactoryBot.define do
  factory :wake_up_log do
    association :user
    association :challenge
    target_date { Date.today }
    pressed_at { Time.current }
    status { :success }
  end
end