FactoryBot.define do
  factory :participation do
    association :user
    association :challenge
  end
end
