FactoryBot.define do
  factory :payment do
    association :brand
    association :booking
    stripe_payment_intent_id { "pi_#{SecureRandom.hex(24)}" }
    stripe_checkout_session_id { "cs_#{SecureRandom.hex(24)}" }
    amount { 99.99 }
    currency { "eur" }
    status { "pending" }
    payment_url { "https://checkout.stripe.com/pay/#{SecureRandom.hex(16)}" }
    metadata { { 'source' => 'web', 'campaign' => 'test' } }
  end
end
