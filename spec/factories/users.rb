FactoryBot.define do
  factory :user do
    name                  { "Test User" }
    email                 { Faker::Internet.unique.email }
    password              { "password123" }
    password_confirmation { "password123" }
    provider              { nil }
    uid                   { nil }
    image                 { nil }

    trait :client do
      role { :client }
    end

    trait :freelancer do
      role { :freelancer }
    end

    # Optional trait for convenience in API tests
    trait :with_token do
      after(:create) do |user|
        create(:doorkeeper_access_token, resource_owner_id: user.id, scopes: 'read write')
      end
    end
  end
end
