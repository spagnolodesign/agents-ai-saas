class Template < ApplicationRecord
  # NOT tenant-scoped - templates are global

  # Associations
  has_many :brand_templates, dependent: :destroy
  has_many :brands, through: :brand_templates

  # Validations
  validates :name, presence: true
  validates :base_prompt, presence: true
end
