require 'rails_helper'

RSpec.describe Conversation, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:conversation_attributes) do
    attributes_for(:conversation, brand: brand, customer: customer)
  end

  describe 'validations' do
    it 'requires status' do
      conversation = Conversation.new(conversation_attributes.except(:status))
      expect(conversation).not_to be_valid
      expect(conversation.errors[:status]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      conversation = Conversation.new(conversation_attributes.except(:brand_id, :brand))
      expect { conversation.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires customer_id' do
      conversation = Conversation.new(conversation_attributes.except(:customer_id, :customer))
      expect { conversation.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      conversation = create(:conversation, brand: brand, customer: customer)
      expect(conversation.brand).to eq(brand)
    end

    it 'belongs to customer' do
      conversation = create(:conversation, brand: brand, customer: customer)
      expect(conversation.customer).to eq(customer)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for messages' do
      messages = [ { 'role' => 'user', 'content' => 'Hello' }, { 'role' => 'assistant', 'content' => 'Hi there' } ]
      conversation = create(:conversation, brand: brand, customer: customer, messages: messages)

      expect(conversation.messages).to eq(messages)
      expect(conversation.messages).to be_an(Array)
    end

    it 'can store empty array for messages' do
      conversation = create(:conversation, brand: brand, customer: customer, messages: [])
      expect(conversation.messages).to eq([])
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      customer1 = create(:customer, brand: brand1)
      customer2 = create(:customer, brand: brand2)

      ActsAsTenant.current_tenant = brand1
      conversation1 = create(:conversation, brand: brand1, customer: customer1)

      ActsAsTenant.current_tenant = brand2
      conversation2 = create(:conversation, brand: brand2, customer: customer2)

      ActsAsTenant.current_tenant = brand1
      expect(Conversation.all).to contain_exactly(conversation1)
    end
  end
end
