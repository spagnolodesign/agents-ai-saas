require 'rails_helper'

RSpec.describe Payment, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:booking) { create(:booking, brand: brand, customer: customer) }
  let(:payment_attributes) do
    attributes_for(:payment, brand: brand, booking: booking)
  end

  describe 'validations' do
    it 'requires brand' do
      ActsAsTenant.current_tenant = nil
      payment = Payment.new(payment_attributes.except(:brand_id, :brand))
      expect { payment.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires booking' do
      payment = Payment.new(payment_attributes.except(:booking_id, :booking))
      expect { payment.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires amount' do
      payment = Payment.new(payment_attributes.except(:amount))
      expect(payment).not_to be_valid
      expect(payment.errors[:amount]).to include("can't be blank")
    end

    it 'requires amount to be greater than 0' do
      payment = Payment.new(payment_attributes.merge(amount: 0))
      expect(payment).not_to be_valid
      expect(payment.errors[:amount]).to include("must be greater than 0")
    end

    it 'rejects negative amounts' do
      payment = Payment.new(payment_attributes.merge(amount: -10))
      expect(payment).not_to be_valid
      expect(payment.errors[:amount]).to include("must be greater than 0")
    end

    it 'requires currency' do
      payment = Payment.new(payment_attributes.except(:currency).merge(currency: nil))
      expect(payment).not_to be_valid
      expect(payment.errors[:currency]).to include("can't be blank")
    end

    it 'requires status' do
      payment = Payment.new(payment_attributes.except(:status))
      expect(payment).not_to be_valid
      expect(payment.errors[:status]).to include("can't be blank")
    end

    it 'validates status inclusion' do
      payment = Payment.new(payment_attributes.merge(status: 'invalid_status'))
      expect(payment).not_to be_valid
      expect(payment.errors[:status]).to include("is not included in the list")
    end

    it 'accepts valid statuses' do
      valid_statuses = %w[pending requires_action processing paid failed canceled]
      valid_statuses.each do |status|
        payment = create(:payment, brand: brand, booking: booking, status: status)
        expect(payment).to be_valid
        expect(payment.status).to eq(status)
      end
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      payment = create(:payment, brand: brand, booking: booking)
      expect(payment.brand).to eq(brand)
    end

    it 'belongs to booking' do
      payment = create(:payment, brand: brand, booking: booking)
      expect(payment.booking).to eq(booking)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for metadata' do
      metadata = { 'source' => 'web', 'campaign' => 'summer2024', 'discount' => 10 }
      payment = create(:payment, brand: brand, booking: booking, metadata: metadata)

      expect(payment.metadata).to eq(metadata)
      expect(payment.metadata['source']).to eq('web')
    end

    it 'can store empty hash for metadata' do
      payment = create(:payment, brand: brand, booking: booking, metadata: {})
      expect(payment.metadata).to eq({})
    end

    it 'uses string keys in metadata' do
      metadata = { 'stripe_customer_id' => 'cus_123', 'invoice_id' => 'inv_456' }
      payment = create(:payment, brand: brand, booking: booking, metadata: metadata)
      expect(payment.metadata.keys.all? { |k| k.is_a?(String) }).to be true
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      customer1 = create(:customer, brand: brand1)
      customer2 = create(:customer, brand: brand2)
      booking1 = create(:booking, brand: brand1, customer: customer1)
      booking2 = create(:booking, brand: brand2, customer: customer2)

      ActsAsTenant.current_tenant = brand1
      payment1 = create(:payment, brand: brand1, booking: booking1)

      ActsAsTenant.current_tenant = brand2
      payment2 = create(:payment, brand: brand2, booking: booking2)

      ActsAsTenant.current_tenant = brand1
      expect(Payment.all).to contain_exactly(payment1)
    end
  end

  describe 'default values' do
    it 'defaults currency to eur' do
      payment = Payment.new(payment_attributes.except(:currency))
      payment.valid? # trigger validations to set defaults
      expect(payment.currency).to eq('eur')
    end

    it 'defaults metadata to empty hash' do
      payment = Payment.new(payment_attributes.except(:metadata))
      expect(payment.metadata).to eq({})
    end
  end
end
