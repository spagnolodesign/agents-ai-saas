class Workflow < ApplicationRecord
  belongs_to :brand

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :name, presence: true
  validates :enabled, inclusion: { in: [true, false] }
end
