class Invoice < ApplicationRecord
  belongs_to :brand
  belongs_to :booking
  belongs_to :payment

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :brand, presence: true
  validates :booking, presence: true
  validates :payment, presence: true
  validates :number, presence: true, uniqueness: { scope: :brand_id }
  validates :status, presence: true, inclusion: { in: %w[draft issued sent] }
end
