class Booking < ApplicationRecord
  belongs_to :brand
  belongs_to :customer

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :service_type, presence: true
  validates :date, presence: true
  validates :status, presence: true
end
