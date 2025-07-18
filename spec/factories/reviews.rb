FactoryBot.define do
  factory :review do
    association :reviewer, factory: [:user, :client]
    association :reviewee, factory: [:user, :freelancer]
    association :project

    ratings { rand(1..5) }
    review  { "The project has been carried out excellently" }
  end
end
