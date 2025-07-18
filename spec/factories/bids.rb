FactoryBot.define do
  factory :bid do
    association :user
    association :project
    proposed_price { 1000.00 }
    cover_letter { "https://mail.google.com/mail/u/0/#inbox" }
    accepted { false } # <-- Important fix
  end
end
