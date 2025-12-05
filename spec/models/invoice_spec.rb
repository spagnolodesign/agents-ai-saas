require 'rails_helper'

RSpec.describe Invoice, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:booking) { create(:booking, brand: brand, customer: customer) }
  let(:payment) { create(:payment, brand: brand, booking: booking) }
  let(:invoice_attributes) do
    attributes_for(:invoice, brand: brand, booking: booking, payment: payment)
  end

  describe 'validations' do
    it 'requires brand' do
      ActsAsTenant.current_tenant = nil
      invoice = Invoice.new(invoice_attributes.except(:brand_id, :brand))
      expect { invoice.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires booking' do
      invoice = Invoice.new(invoice_attributes.except(:booking_id, :booking))
      expect { invoice.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires payment' do
      invoice = Invoice.new(invoice_attributes.except(:payment_id, :payment))
      expect { invoice.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires number' do
      invoice = Invoice.new(invoice_attributes.except(:number))
      expect(invoice).not_to be_valid
      expect(invoice.errors[:number]).to include("can't be blank")
    end

    it 'requires status' do
      invoice = Invoice.new(invoice_attributes.except(:status))
      expect(invoice).not_to be_valid
      expect(invoice.errors[:status]).to include("can't be blank")
    end

    it 'validates status inclusion' do
      invoice = Invoice.new(invoice_attributes.merge(status: 'invalid_status'))
      expect(invoice).not_to be_valid
      expect(invoice.errors[:status]).to include("is not included in the list")
    end

    it 'accepts valid statuses' do
      valid_statuses = %w[draft issued sent]
      valid_statuses.each do |status|
        invoice = create(:invoice, brand: brand, booking: booking, payment: payment, status: status)
        expect(invoice).to be_valid
        expect(invoice.status).to eq(status)
      end
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment)
      expect(invoice.brand).to eq(brand)
    end

    it 'belongs to booking' do
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment)
      expect(invoice.booking).to eq(booking)
    end

    it 'belongs to payment' do
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment)
      expect(invoice.payment).to eq(payment)
    end
  end

  describe 'uniqueness of invoice number scoped to brand' do
    it 'validates uniqueness of number scoped to brand' do
      create(:invoice, brand: brand, booking: booking, payment: payment, number: 'INV-12345')
      duplicate = build(:invoice, brand: brand, booking: booking, payment: payment, number: 'INV-12345')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:number]).to include("has already been taken")
    end

    it 'allows same invoice number for different brands' do
      brand2 = create(:brand, subdomain: 'brand2')
      customer2 = create(:customer, brand: brand2)
      booking2 = create(:booking, brand: brand2, customer: customer2)
      payment2 = create(:payment, brand: brand2, booking: booking2)

      create(:invoice, brand: brand, booking: booking, payment: payment, number: 'INV-12345')
      invoice2 = build(:invoice, brand: brand2, booking: booking2, payment: payment2, number: 'INV-12345')

      expect(invoice2).to be_valid
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for metadata' do
      metadata = { 'source' => 'web', 'campaign' => 'summer2024', 'discount' => 10 }
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment, metadata: metadata)

      expect(invoice.metadata).to eq(metadata)
      expect(invoice.metadata['source']).to eq('web')
    end

    it 'can store empty hash for metadata' do
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment, metadata: {})
      expect(invoice.metadata).to eq({})
    end

    it 'uses string keys in metadata' do
      metadata = { 'invoice_type' => 'standard', 'tax_rate' => 0.2 }
      invoice = create(:invoice, brand: brand, booking: booking, payment: payment, metadata: metadata)
      expect(invoice.metadata.keys.all? { |k| k.is_a?(String) }).to be true
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
      payment1 = create(:payment, brand: brand1, booking: booking1)
      payment2 = create(:payment, brand: brand2, booking: booking2)

      ActsAsTenant.current_tenant = brand1
      invoice1 = create(:invoice, brand: brand1, booking: booking1, payment: payment1)

      ActsAsTenant.current_tenant = brand2
      invoice2 = create(:invoice, brand: brand2, booking: booking2, payment: payment2)

      ActsAsTenant.current_tenant = brand1
      expect(Invoice.all).to contain_exactly(invoice1)
    end
  end

  describe 'default values' do
    it 'defaults metadata to empty hash' do
      invoice = Invoice.new(invoice_attributes.except(:metadata))
      expect(invoice.metadata).to eq({})
    end
  end
end
