require 'rails_helper'

RSpec.describe Customer, type: :model do
  let(:brand) { create(:brand) }
  let(:customer_attributes) { attributes_for(:customer, brand: brand) }

  describe 'validations' do
    it 'requires name' do
      customer = Customer.new(customer_attributes.except(:name))
      expect(customer).not_to be_valid
      expect(customer.errors[:name]).to include("can't be blank")
    end

    it 'requires email' do
      customer = Customer.new(customer_attributes.except(:email))
      expect(customer).not_to be_valid
      expect(customer.errors[:email]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      customer = Customer.new(customer_attributes.except(:brand_id, :brand))
      expect { customer.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      customer = create(:customer, brand: brand)
      expect(customer.brand).to eq(brand)
    end

    it 'has many conversations' do
      customer = create(:customer, brand: brand)
      conversation = create(:conversation, customer: customer, brand: brand)
      expect(customer.conversations).to include(conversation)
    end

    it 'has many bookings' do
      customer = create(:customer, brand: brand)
      booking = create(:booking, customer: customer, brand: brand)
      expect(customer.bookings).to include(booking)
    end

    it 'has many leads' do
      customer = create(:customer, brand: brand)
      lead = create(:lead, customer: customer, brand: brand)
      expect(customer.leads).to include(lead)
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')

      ActsAsTenant.current_tenant = brand1
      customer1 = create(:customer, brand: brand1)

      ActsAsTenant.current_tenant = brand2
      customer2 = create(:customer, brand: brand2)

      ActsAsTenant.current_tenant = brand1
      expect(Customer.all).to contain_exactly(customer1)

      ActsAsTenant.current_tenant = brand2
      expect(Customer.all).to contain_exactly(customer2)
    end
  end
end
