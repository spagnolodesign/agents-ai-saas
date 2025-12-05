require 'rails_helper'

RSpec.describe Workflow, type: :model do
  let(:brand) { create(:brand) }
  let(:workflow_attributes) { attributes_for(:workflow, brand: brand) }

  describe 'validations' do
    it 'requires name' do
      workflow = Workflow.new(workflow_attributes.except(:name))
      expect(workflow).not_to be_valid
      expect(workflow.errors[:name]).to include("can't be blank")
    end

    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      workflow = Workflow.new(workflow_attributes.except(:brand_id, :brand))
      expect { workflow.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'validates enabled inclusion' do
      workflow = Workflow.new(workflow_attributes.merge(enabled: nil))
      expect(workflow).not_to be_valid
      expect(workflow.errors[:enabled]).to include("is not included in the list")
    end

    it 'accepts true for enabled' do
      workflow = create(:workflow, brand: brand, enabled: true)
      expect(workflow.enabled).to be true
    end

    it 'accepts false for enabled' do
      workflow = create(:workflow, brand: brand, enabled: false)
      expect(workflow.enabled).to be false
    end

    it 'defaults enabled to false' do
      workflow = Workflow.new(workflow_attributes.except(:enabled))
      expect(workflow.enabled).to be false
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      workflow = create(:workflow, brand: brand)
      expect(workflow.brand).to eq(brand)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for steps' do
      steps = [
        { 'type' => 'send_message', 'content' => 'Hello' },
        { 'type' => 'wait_for_response', 'timeout' => 30 },
        { 'type' => 'process_response', 'action' => 'extract_info' }
      ]
      workflow = create(:workflow, brand: brand, steps: steps)

      expect(workflow.steps).to eq(steps)
      expect(workflow.steps).to be_an(Array)
      expect(workflow.steps.first['type']).to eq('send_message')
    end

    it 'can store empty array for steps' do
      workflow = create(:workflow, brand: brand, steps: [])
      expect(workflow.steps).to eq([])
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')

      ActsAsTenant.current_tenant = brand1
      workflow1 = create(:workflow, brand: brand1)

      ActsAsTenant.current_tenant = brand2
      workflow2 = create(:workflow, brand: brand2)

      ActsAsTenant.current_tenant = brand1
      expect(Workflow.all).to contain_exactly(workflow1)
    end
  end
end
