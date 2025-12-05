class Payment < ApplicationRecord
  belongs_to :brand
  belongs_to :booking

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :brand, presence: true
  validates :booking, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending requires_action processing paid failed canceled] }
end
