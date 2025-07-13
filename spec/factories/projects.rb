FactoryBot.define do
  factory :project do
    sequence(:title) { |n| "Valid Project Title #{n} #{SecureRandom.hex(2)}" }
    description { "A valid description for the project." }
    budget { 1000 }
    deadline { 7.days.from_now }
    association :client, factory: :user
  end
end
