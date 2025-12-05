FactoryBot.define do
  factory :brand_template do
    association :brand
    association :template
    custom_prompt { Faker::Lorem.paragraph }
    overrides { {} }
  end
end
