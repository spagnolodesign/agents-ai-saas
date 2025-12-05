require 'rails_helper'

RSpec.describe User, type: :model do
  let(:brand) { create(:brand) }
  let(:user_attributes) { attributes_for(:user, brand: brand) }

  describe 'validations' do
    it 'requires name' do
      user = User.new(user_attributes.except(:name))
      expect(user).not_to be_valid
      expect(user.errors[:name]).to include("can't be blank")
    end

    it 'requires email' do
      user = User.new(user_attributes.except(:email))
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it 'requires role' do
      user = User.new(user_attributes.except(:role))
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end

    it 'requires brand_id' do
      # belongs_to :brand creates the association requirement
      # Database constraint enforces brand_id presence (null: false)
      ActsAsTenant.current_tenant = nil
      user = User.new(user_attributes.except(:brand_id, :brand))
      
      # The brand association is required
      expect(user.brand).to be_nil
      # When saving, it will fail due to database constraint or association requirement
      expect { user.save! }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'requires password' do
      user = User.new(user_attributes.except(:password, :password_confirmation))
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'validates email uniqueness scoped to brand' do
      create(:user, email: 'test@example.com', brand: brand)
      duplicate_user = build(:user, email: 'test@example.com', brand: brand)
      
      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include("has already been taken")
    end

    it 'allows same email for different brands' do
      brand2 = create(:brand, subdomain: 'brand2')
      create(:user, email: 'test@example.com', brand: brand)
      user2 = build(:user, email: 'test@example.com', brand: brand2)
      
      expect(user2).to be_valid
    end
  end

  describe 'associations' do
    it 'belongs to brand' do
      user = create(:user, brand: brand)
      expect(user.brand).to eq(brand)
    end
  end

  describe 'tenant scoping' do
    it 'is tenant-scoped' do
      brand1 = create(:brand, subdomain: 'brand1')
      brand2 = create(:brand, subdomain: 'brand2')
      
      ActsAsTenant.current_tenant = brand1
      user1 = create(:user, brand: brand1)
      
      ActsAsTenant.current_tenant = brand2
      user2 = create(:user, brand: brand2)
      
      # When tenant is brand1, only user1 should be visible
      ActsAsTenant.current_tenant = brand1
      expect(User.all).to contain_exactly(user1)
      
      # When tenant is brand2, only user2 should be visible
      ActsAsTenant.current_tenant = brand2
      expect(User.all).to contain_exactly(user2)
    end
  end

  describe 'authentication' do
    it 'has secure password' do
      user = create(:user, password: 'password123', password_confirmation: 'password123')
      expect(user.authenticate('password123')).to eq(user)
      expect(user.authenticate('wrong_password')).to be false
    end
  end
end
