FactoryBot.define do
  factory :user do
    name { "テストユーザー" }
    sequence(:email) { |n| "test#{n}@example.com" }
    # sequence(:email) { "test1@example.com" }

    password { "password123" }
    password_confirmation { "password123" }

    # googleログイン認証用の属性
    trait :google_user do
      provider { 'google_oauth2' }
      sequence(:uid) { |n| "google_uid_#{n}" }
    end
  end
end