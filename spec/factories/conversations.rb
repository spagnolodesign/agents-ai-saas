FactoryBot.define do
  factory :conversation do
    association :brand
    association :customer
    messages { [] }
    status { "active" }
    last_message_at { Time.current }
  end
end
