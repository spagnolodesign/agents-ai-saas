class AnsweredField < ApplicationRecord
  belongs_to :lead

  # Tenant scoping through lead
  # Note: AnsweredField doesn't have brand_id directly, but is scoped through lead
  # We can access brand via lead.brand

  # Validations
  validates :field_name, presence: true
end
