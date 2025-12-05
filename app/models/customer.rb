class Customer < ApplicationRecord
  belongs_to :brand

  # Tenant scoping
  acts_as_tenant :brand

  # Associations
  has_many :conversations, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :leads, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true
end
