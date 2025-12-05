FactoryBot.define do
  factory :booking do
    association :brand
    association :customer
    service_type { "consultation" }
    date { Date.tomorrow }
    time { Time.current + 1.day }
    status { "pending" }
    notes { Faker::Lorem.paragraph }
    metadata { {} }
  end
end
