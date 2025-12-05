FactoryBot.define do
  factory :customer do
    association :brand
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    codice_fiscale { "RSSMRA85T10A562S" }
  end
end
