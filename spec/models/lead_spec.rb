require 'rails_helper'

RSpec.describe Lead, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:lead_attributes) { attributes_for(:lead, brand: brand, customer: customer) }

  describe 'validations' do
    it 'requires form_type' do
      lead = Lead.new(lead_attributes.except(:form_type))
      expect(lead).not_to be_valid
      expect(lead.errors[:form_type]).to include("can't be blank")
    end

    it 'requires status' do
      lead = Lead.new(lead_attributes.except(:status))
      expect(lead).not_to be_valid
      expect(lead.errors[:status]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      lead = Lead.new(lead_attributes.except(:brand_id, :brand))
      expect { lead.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires customer_id' do
      lead = Lead.new(lead_attributes.except(:customer_id, :customer))
      expect { lead.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      lead = create(:lead, brand: brand, customer: customer)
      expect(lead.brand).to eq(brand)
    end

    it 'belongs to customer' do
      lead = create(:lead, brand: brand, customer: customer)
      expect(lead.customer).to eq(customer)
    end

    it 'has many answered_fields' do
      lead = create(:lead, brand: brand, customer: customer)
      answered_field = create(:answered_field, lead: lead)
      expect(lead.answered_fields).to include(answered_field)
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      customer1 = create(:customer, brand: brand1)
      customer2 = create(:customer, brand: brand2)

      ActsAsTenant.current_tenant = brand1
      lead1 = create(:lead, brand: brand1, customer: customer1)

      ActsAsTenant.current_tenant = brand2
      lead2 = create(:lead, brand: brand2, customer: customer2)

      ActsAsTenant.current_tenant = brand1
      expect(Lead.all).to contain_exactly(lead1)
    end
  end
end
