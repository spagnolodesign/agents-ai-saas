FactoryBot.define do
  factory :customer do
    association :brand
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
  end
end
