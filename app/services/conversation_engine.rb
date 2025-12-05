class ConversationEngine
  def process(conversation:, user_message:)
    # 1. Save user message
    Message.create!(
      conversation: conversation,
      role: "user",
      content: user_message
    )

    # 2. Restore workflow context
    stored = conversation.workflow_context || {}
    context = Workflows::WorkflowContext.new(stored)
    context.customer = conversation.customer
    # Pass conversation ID to context (not the object to avoid circular references)
    context.set(:conversation_id, conversation.id)

    # 3. Select workflow (prefer "Chat Workflow" for conversational AI, then "Booking Workflow")
    workflow = Workflow.where(brand: conversation.brand, enabled: true, name: "Chat Workflow").first ||
               Workflow.where(brand: conversation.brand, enabled: true, name: "Booking Workflow").first ||
               Workflow.where(brand: conversation.brand, enabled: true).first
    raise "No workflow found for brand #{conversation.brand.id}" unless workflow

    # 4. Execute workflow
    engine = Workflows::WorkflowEngine.new(workflow: workflow, context: context)
    reply = engine.execute

    # 5. Persist updated context
    conversation.update!(workflow_context: context.to_h)

    # 6. Save assistant message if present
    if reply.present?
      Message.create!(
        conversation: conversation,
        role: "assistant",
        content: reply
      )
    end

    # 7. Return reply (may be nil if waiting for user input)
    reply
  end
end
