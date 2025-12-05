class Event < ApplicationRecord
  belongs_to :brand

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :event_type, presence: true
  validates :occurred_at, presence: true
end
