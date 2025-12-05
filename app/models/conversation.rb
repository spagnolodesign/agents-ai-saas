class Conversation < ApplicationRecord
  belongs_to :brand
  belongs_to :customer

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :status, presence: true
end
