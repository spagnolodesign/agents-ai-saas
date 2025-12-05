class User < ApplicationRecord
  belongs_to :brand

  # Tenant scoping
  acts_as_tenant :brand

  # Authentication
  has_secure_password

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :brand_id }
  validates :role, presence: true
end
