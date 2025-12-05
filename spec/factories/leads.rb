FactoryBot.define do
  factory :lead do
    association :brand
    association :customer
    form_type { "contact" }
    status { "new" }
  end
end
