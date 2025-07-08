FactoryBot.define do
  factory :comment do
    association :user
    association :project
    body { "what technology is incomming in your company for this project?" }

    trait :with_parent do
      association :parent, factory: :comment
    end
  end
end
