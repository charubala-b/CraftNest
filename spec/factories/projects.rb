FactoryBot.define do
    factory :project do
        sequence(:title) { |n| "Unique Project Title is Title #{n}" }
        description { "The dashboard for getting job through online" }
        budget { "1000" }
        deadline { 2.weeks.from_now }
        association :client, factory: :user
    end
end

