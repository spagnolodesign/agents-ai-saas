FactoryBot.define do
  factory :invoice do
    association :brand
    association :booking
    association :payment
    number { "INV-#{SecureRandom.alphanumeric(8).upcase}" }
    pdf_url { "https://example.com/invoices/#{SecureRandom.hex(16)}.pdf" }
    status { "draft" }
    metadata { { 'source' => 'web', 'campaign' => 'test' } }
  end
end
