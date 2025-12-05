class UpdateConversationsForStep7 < ActiveRecord::Migration[7.2]
  def change
    # 1. Remove old messages column
    remove_column :conversations, :messages, :jsonb

    # 2. Allow customer to be null
    change_column_null :conversations, :customer_id, true

    # 3. Add workflow_context jsonb
    add_column :conversations, :workflow_context, :jsonb, default: {}

    # 4. Set default status
    change_column_default :conversations, :status, from: nil, to: "active"
  end
end

