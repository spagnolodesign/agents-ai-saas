FactoryBot.define do
  factory :template do
    name { Faker::Lorem.word }
    base_prompt { Faker::Lorem.paragraph }
    workflow_definition { {} }
  end
end
