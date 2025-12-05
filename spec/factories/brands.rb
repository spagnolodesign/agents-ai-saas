FactoryBot.define do
  factory :brand do
    name { Faker::Company.name }
    subdomain { Faker::Internet.domain_word }
    settings { {} }
  end
end
