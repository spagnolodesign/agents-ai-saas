class BrandTemplate < ApplicationRecord
  belongs_to :brand
  belongs_to :template

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :brand_id, uniqueness: { scope: :template_id }
end
