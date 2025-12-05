require 'rails_helper'

RSpec.describe Booking, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:booking_attributes) do
    attributes_for(:booking, brand: brand, customer: customer)
  end

  describe 'validations' do
    it 'requires service_type' do
      booking = Booking.new(booking_attributes.except(:service_type))
      expect(booking).not_to be_valid
      expect(booking.errors[:service_type]).to include("can't be blank")
    end

    it 'requires date' do
      booking = Booking.new(booking_attributes.except(:date))
      expect(booking).not_to be_valid
      expect(booking.errors[:date]).to include("can't be blank")
    end

    it 'requires status' do
      booking = Booking.new(booking_attributes.except(:status))
      expect(booking).not_to be_valid
      expect(booking.errors[:status]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      booking = Booking.new(booking_attributes.except(:brand_id, :brand))
      expect { booking.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires customer_id' do
      booking = Booking.new(booking_attributes.except(:customer_id, :customer))
      expect { booking.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      booking = create(:booking, brand: brand, customer: customer)
      expect(booking.brand).to eq(brand)
    end

    it 'belongs to customer' do
      booking = create(:booking, brand: brand, customer: customer)
      expect(booking.customer).to eq(customer)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for metadata' do
      metadata = { 'source' => 'web', 'campaign' => 'summer2024', 'discount' => 10 }
      booking = create(:booking, brand: brand, customer: customer, metadata: metadata)

      expect(booking.metadata).to eq(metadata)
      expect(booking.metadata['source']).to eq('web')
    end

    it 'can store empty hash for metadata' do
      booking = create(:booking, brand: brand, customer: customer, metadata: {})
      expect(booking.metadata).to eq({})
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      customer1 = create(:customer, brand: brand1)
      customer2 = create(:customer, brand: brand2)

      ActsAsTenant.current_tenant = brand1
      booking1 = create(:booking, brand: brand1, customer: customer1)

      ActsAsTenant.current_tenant = brand2
      booking2 = create(:booking, brand: brand2, customer: customer2)

      ActsAsTenant.current_tenant = brand1
      expect(Booking.all).to contain_exactly(booking1)
    end
  end
end
