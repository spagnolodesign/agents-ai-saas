FactoryBot.define do
  factory :event do
    association :brand
    event_type { "conversation_started" }
    occurred_at { Time.current }
    payload { {} }
  end
end
