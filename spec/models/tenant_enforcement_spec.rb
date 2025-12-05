require 'rails_helper'

RSpec.describe 'Tenant Enforcement', type: :model do
  let(:brand_a) { create(:brand, subdomain: 'branda', name: 'Brand A') }
  let(:brand_b) { create(:brand, subdomain: 'brandb', name: 'Brand B') }

  describe 'tenant isolation' do
    it 'prevents access to records from different tenants' do
      # Create a user under brand A
      ActsAsTenant.current_tenant = brand_a
      user_a = create(:user, brand: brand_a, email: 'user@branda.com')
      customer_a = create(:customer, brand: brand_a, email: 'customer@branda.com')
      conversation_a = create(:conversation, brand: brand_a, customer: customer_a)
      booking_a = create(:booking, brand: brand_a, customer: customer_a)
      lead_a = create(:lead, brand: brand_a, customer: customer_a)
      workflow_a = create(:workflow, brand: brand_a)
      event_a = create(:event, brand: brand_a)

      # Switch to brand B
      ActsAsTenant.current_tenant = brand_b

      # Records from brand A should NOT be accessible
      expect(User.find_by(id: user_a.id)).to be_nil
      expect(Customer.find_by(id: customer_a.id)).to be_nil
      expect(Conversation.find_by(id: conversation_a.id)).to be_nil
      expect(Booking.find_by(id: booking_a.id)).to be_nil
      expect(Lead.find_by(id: lead_a.id)).to be_nil
      expect(Workflow.find_by(id: workflow_a.id)).to be_nil
      expect(Event.find_by(id: event_a.id)).to be_nil

      # Querying all records should return empty
      expect(User.all).to be_empty
      expect(Customer.all).to be_empty
      expect(Conversation.all).to be_empty
      expect(Booking.all).to be_empty
      expect(Lead.all).to be_empty
      expect(Workflow.all).to be_empty
      expect(Event.all).to be_empty
    end

    it 'allows access to records within the same tenant' do
      # Create records under brand A
      ActsAsTenant.current_tenant = brand_a
      user_a = create(:user, brand: brand_a)
      customer_a = create(:customer, brand: brand_a)

      # Records should be accessible within the same tenant
      expect(User.find(user_a.id)).to eq(user_a)
      expect(Customer.find(customer_a.id)).to eq(customer_a)
      expect(User.all).to include(user_a)
      expect(Customer.all).to include(customer_a)
    end

    it 'enforces tenant scoping when creating records' do
      ActsAsTenant.current_tenant = brand_a
      user = User.new(attributes_for(:user).except(:brand_id))
      user.email = 'test@example.com'
      user.password = 'password123'
      user.password_confirmation = 'password123'
      user.role = 'admin'
      user.name = 'Test User'

      expect { user.save! }.to change { User.count }.by(1)
      expect(user.brand_id).to eq(brand_a.id)
    end

    it 'prevents cross-tenant record creation' do
      ActsAsTenant.current_tenant = brand_a
      customer_a = create(:customer, brand: brand_a)

      # Try to create a conversation with customer from brand_a but brand set to brand_b
      ActsAsTenant.current_tenant = brand_b
      conversation = Conversation.new(
        customer: customer_a,
        brand: brand_b,
        status: 'active',
        messages: []
      )

      # This should fail because customer belongs to brand_a but conversation is for brand_b
      # The foreign key constraint or validation should prevent this
      expect(conversation).not_to be_valid
    end
  end

  describe 'tenant scoping for different models' do
    it 'scopes User queries to current tenant' do
      ActsAsTenant.current_tenant = brand_a
      user_a = create(:user, brand: brand_a)

      ActsAsTenant.current_tenant = brand_b
      user_b = create(:user, brand: brand_b)

      ActsAsTenant.current_tenant = brand_a
      expect(User.all).to contain_exactly(user_a)

      ActsAsTenant.current_tenant = brand_b
      expect(User.all).to contain_exactly(user_b)
    end

    it 'scopes Customer queries to current tenant' do
      ActsAsTenant.current_tenant = brand_a
      customer_a = create(:customer, brand: brand_a)

      ActsAsTenant.current_tenant = brand_b
      customer_b = create(:customer, brand: brand_b)

      ActsAsTenant.current_tenant = brand_a
      expect(Customer.all).to contain_exactly(customer_a)

      ActsAsTenant.current_tenant = brand_b
      expect(Customer.all).to contain_exactly(customer_b)
    end

    it 'scopes Workflow queries to current tenant' do
      ActsAsTenant.current_tenant = brand_a
      workflow_a = create(:workflow, brand: brand_a)

      ActsAsTenant.current_tenant = brand_b
      workflow_b = create(:workflow, brand: brand_b)

      ActsAsTenant.current_tenant = brand_a
      expect(Workflow.all).to contain_exactly(workflow_a)

      ActsAsTenant.current_tenant = brand_b
      expect(Workflow.all).to contain_exactly(workflow_b)
    end
  end
end
