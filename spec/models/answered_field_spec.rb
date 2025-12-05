require 'rails_helper'

RSpec.describe AnsweredField, type: :model do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:lead) { create(:lead, brand: brand, customer: customer) }
  let(:answered_field_attributes) { attributes_for(:answered_field, lead: lead) }

  describe 'validations' do
    it 'requires field_name' do
      answered_field = AnsweredField.new(answered_field_attributes.except(:field_name))
      expect(answered_field).not_to be_valid
      expect(answered_field.errors[:field_name]).to include("can't be blank")
    end

    it 'requires lead_id' do
      answered_field = AnsweredField.new(answered_field_attributes.except(:lead_id, :lead))
      expect { answered_field.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  describe 'associations' do
    it 'belongs to lead' do
      answered_field = create(:answered_field, lead: lead)
      expect(answered_field.lead).to eq(lead)
    end
  end
end
