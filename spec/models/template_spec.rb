require 'rails_helper'

RSpec.describe Template, type: :model do
  let(:template_attributes) { attributes_for(:template) }

  describe 'validations' do
    it 'requires name' do
      template = Template.new(template_attributes.except(:name))
      expect(template).not_to be_valid
      expect(template.errors[:name]).to include("can't be blank")
    end

    it 'requires base_prompt' do
      template = Template.new(template_attributes.except(:base_prompt))
      expect(template).not_to be_valid
      expect(template.errors[:base_prompt]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many brand_templates' do
      template = create(:template)
      brand = create(:brand)
      brand_template = create(:brand_template, template: template, brand: brand)
      expect(template.brand_templates).to include(brand_template)
    end

    it 'has many brands through brand_templates' do
      template = create(:template)
      brand = create(:brand)
      create(:brand_template, template: template, brand: brand)
      expect(template.brands).to include(brand)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for workflow_definition' do
      workflow_definition = {
        'steps' => [
          { 'type' => 'message', 'content' => 'Hello' },
          { 'type' => 'wait', 'duration' => 5 }
        ]
      }
      template = create(:template, workflow_definition: workflow_definition)
      
      expect(template.workflow_definition).to eq(workflow_definition)
      expect(template.workflow_definition['steps']).to be_an(Array)
    end

    it 'can store empty hash for workflow_definition' do
      template = create(:template, workflow_definition: {})
      expect(template.workflow_definition).to eq({})
    end
  end

  describe 'tenant scoping' do
    it 'is NOT tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      
      ActsAsTenant.current_tenant = brand1
      template1 = create(:template)
      
      ActsAsTenant.current_tenant = brand2
      template2 = create(:template)
      
      # Templates should be visible regardless of tenant
      ActsAsTenant.current_tenant = brand1
      expect(Template.all).to include(template1, template2)
    end
  end
end
