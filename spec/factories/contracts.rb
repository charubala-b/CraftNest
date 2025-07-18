FactoryBot.define do
  factory :contract do
    association :project
    association :client, factory: [:user, :client]
    association :freelancer, factory: [:user, :freelancer]
    start_date { Time.current }
    end_date { 1.month.from_now }
    status { :active }
  end
end
