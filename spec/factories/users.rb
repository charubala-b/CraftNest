FactoryBot.define do
  factory :user do
    name { "Test User" }
    email { Faker::Internet.unique.email }
    password { "password123" }
    password_confirmation { "password123" }
    role { :freelancer }
    provider { nil }
    uid { nil }
    image { nil }
  end
end
