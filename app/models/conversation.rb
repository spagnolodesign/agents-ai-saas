class Conversation < ApplicationRecord
  belongs_to :brand
  belongs_to :customer, optional: true

  has_many :messages, dependent: :destroy

  # Tenant scoping
  acts_as_tenant :brand

  # Validations
  validates :status, presence: true

  # JSONB field for workflow context persistence
  # Stores WorkflowContext state as JSON
  serialize :workflow_context, coder: JSON if respond_to?(:serialize)
end
