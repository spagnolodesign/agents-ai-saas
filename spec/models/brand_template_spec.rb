require 'rails_helper'

RSpec.describe BrandTemplate, type: :model do
  let(:brand) { create(:brand) }
  let(:template) { create(:template) }
  let(:brand_template_attributes) do
    attributes_for(:brand_template, brand: brand, template: template)
  end

  describe 'validations' do
    it 'requires brand_id' do
      ActsAsTenant.current_tenant = nil
      brand_template = BrandTemplate.new(brand_template_attributes.except(:brand_id, :brand))
      expect { brand_template.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires template_id' do
      brand_template = BrandTemplate.new(brand_template_attributes.except(:template_id, :template))
      expect { brand_template.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'validates uniqueness of brand_id scoped to template_id' do
      create(:brand_template, brand: brand, template: template)
      duplicate = build(:brand_template, brand: brand, template: template)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:brand_id]).to be_present
    end

    it 'allows same template for different brands' do
      brand2 = create(:brand, subdomain: 'brand2')
      create(:brand_template, brand: brand, template: template)
      brand_template2 = build(:brand_template, brand: brand2, template: template)
      
      expect(brand_template2).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      brand_template = create(:brand_template, brand: brand, template: template)
      expect(brand_template.brand).to eq(brand)
    end

    it 'belongs to template' do
      brand_template = create(:brand_template, brand: brand, template: template)
      expect(brand_template.template).to eq(template)
    end
  end

  describe 'jsonb fields' do
    it 'accepts jsonb values for overrides' do
      overrides = { 'temperature' => 0.7, 'max_tokens' => 500, 'system_prompt' => 'Custom prompt' }
      brand_template = create(:brand_template, brand: brand, template: template, overrides: overrides)
      
      expect(brand_template.overrides).to eq(overrides)
      expect(brand_template.overrides['temperature']).to eq(0.7)
    end

    it 'can store empty hash for overrides' do
      brand_template = create(:brand_template, brand: brand, template: template, overrides: {})
      expect(brand_template.overrides).to eq({})
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      template = create(:template)
      
      ActsAsTenant.current_tenant = brand1
      brand_template1 = create(:brand_template, brand: brand1, template: template)
      
      ActsAsTenant.current_tenant = brand2
      brand_template2 = create(:brand_template, brand: brand2, template: template)
      
      ActsAsTenant.current_tenant = brand1
      expect(BrandTemplate.all).to contain_exactly(brand_template1)
    end
  end
end
