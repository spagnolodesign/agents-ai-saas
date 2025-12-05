FactoryBot.define do
  factory :workflow do
    association :brand
    name { Faker::Lorem.word }
    steps { [] }
    enabled { false }
  end
end
