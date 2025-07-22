FactoryBot.define do
    factory :message do
        association :sender, factory: :user
        association :receiver, factory: :user
        association :project
        body { "what about the update?" }
    end
end
