FactoryBot.define do
    factory :contract do
        association :project
        association :client, factory: :user, role: :client
        association :freelancer, factory: :user, role: :freelancer
        start_date { Time.current }
        end_date { 1.month.from_now }
        status { :active }
    end
end
