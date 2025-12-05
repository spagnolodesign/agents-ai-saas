class Brand < ApplicationRecord
  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true

  # Associations
  has_many :users, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :conversations, dependent: :destroy
  has_many :bookings, dependent: :destroy
  has_many :leads, dependent: :destroy
  has_many :brand_templates, dependent: :destroy
  has_many :templates, through: :brand_templates
  has_many :workflows, dependent: :destroy
  has_many :events, dependent: :destroy
end
