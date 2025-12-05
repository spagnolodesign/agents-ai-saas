FactoryBot.define do
  factory :answered_field do
    association :lead
    field_name { "name" }
    field_value { Faker::Name.name }
  end
end
