class Lead < ApplicationRecord
  belongs_to :brand
  belongs_to :customer

  # Tenant scoping
  acts_as_tenant :brand

  # Associations
  has_many :answered_fields, dependent: :destroy

  # Validations
  validates :form_type, presence: true
  validates :status, presence: true
end
