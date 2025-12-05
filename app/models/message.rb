class Message < ApplicationRecord
  belongs_to :conversation

  # Validations
  validates :role, presence: true
  validates :content, presence: true
  validates :role, inclusion: { in: %w[user assistant system] }

  # JSONB metadata field
  # Use string keys for JSONB fields
end

