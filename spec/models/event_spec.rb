require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:brand) { create(:brand) }
  let(:event_attributes) { attributes_for(:event, brand: brand) }

  describe 'validations' do
    it 'requires event_type' do
      event = Event.new(event_attributes.except(:event_type))
      expect(event).not_to be_valid
      expect(event.errors[:event_type]).to include("can't be blank")
    end

    it 'requires occurred_at' do
      event = Event.new(event_attributes.except(:occurred_at))
      expect(event).not_to be_valid
      expect(event.errors[:occurred_at]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      event = Event.new(event_attributes.except(:brand_id, :brand))
      expect { event.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      event = create(:event, brand: brand)
      expect(event.brand).to eq(brand)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for payload' do
      payload = {
        'user_id' => 123,
        'action' => 'conversation_started',
        'metadata' => { 'source' => 'web', 'ip' => '192.168.1.1' }
      }
      event = create(:event, brand: brand, payload: payload)
      
      expect(event.payload).to eq(payload)
      expect(event.payload['action']).to eq('conversation_started')
      expect(event.payload['metadata']).to be_a(Hash)
    end

    it 'can store empty hash for payload' do
      event = create(:event, brand: brand, payload: {})
      expect(event.payload).to eq({})
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      
      ActsAsTenant.current_tenant = brand1
      event1 = create(:event, brand: brand1)
      
      ActsAsTenant.current_tenant = brand2
      event2 = create(:event, brand: brand2)
      
      ActsAsTenant.current_tenant = brand1
      expect(Event.all).to contain_exactly(event1)
    end
  end
end
