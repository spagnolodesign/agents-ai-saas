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

    it 'accepts a valid codice_fiscale' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "RSSMRA85T10A562S", brand: brand))
      expect(customer).to be_valid
    end

    it 'accepts an empty codice_fiscale' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "", brand: brand))
      expect(customer).to be_valid
    end

    it 'accepts a nil codice_fiscale' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: nil, brand: brand))
      expect(customer).to be_valid
    end

    it 'rejects an invalid codice_fiscale that is too short' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "RSSMRA85T10A562", brand: brand))
      expect(customer).not_to be_valid
      expect(customer.errors[:codice_fiscale]).to be_present
    end

    it 'rejects an invalid codice_fiscale that is too long' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "RSSMRA85T10A562SS", brand: brand))
      expect(customer).not_to be_valid
      expect(customer.errors[:codice_fiscale]).to be_present
    end

    it 'rejects an invalid codice_fiscale with invalid characters' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "RSSMRA85T10A562-", brand: brand))
      expect(customer).not_to be_valid
      expect(customer.errors[:codice_fiscale]).to be_present
    end

    it 'accepts lowercase codice_fiscale' do
      customer = Customer.new(customer_attributes.merge(codice_fiscale: "rssmra85t10a562s", brand: brand))
      expect(customer).to be_valid
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

  describe 'codice_fiscale' do
    it 'can be saved and retrieved' do
      customer = create(:customer, brand: brand, codice_fiscale: "RSSMRA85T10A562S")
      expect(customer.codice_fiscale).to eq("RSSMRA85T10A562S")
    end

    it 'does not affect tenant scoping' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')

      ActsAsTenant.current_tenant = brand1
      customer1 = create(:customer, brand: brand1, codice_fiscale: "RSSMRA85T10A562S")

      ActsAsTenant.current_tenant = brand2
      customer2 = create(:customer, brand: brand2, codice_fiscale: "RSSMRA85T10A562S")

      ActsAsTenant.current_tenant = brand1
      expect(Customer.all).to contain_exactly(customer1)
    end
  end
end
