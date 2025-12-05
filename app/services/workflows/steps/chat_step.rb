module Workflows
  module Steps
    # ChatStep generates conversational AI responses based on message history.
    # It uses the conversation's message history to maintain context and generate natural responses.
    #
    # Example step:
    # {
    #   "type": "chat",
    #   "system_prompt": "You are a helpful assistant for booking appointments..."
    # }
    class ChatStep < BaseStep
      def call
        # Get conversation ID from context (set by ConversationEngine)
        conversation_id = context.get(:conversation_id)
        return "I'm sorry, I couldn't access the conversation." unless conversation_id

        # Load conversation from database
        conversation = Conversation.find_by(id: conversation_id)
        return "I'm sorry, I couldn't find the conversation." unless conversation

        # Memory Bank Pattern: Extract and maintain only key information
        # Instead of sending all messages, we extract structured data
        all_messages = conversation.messages.order(:created_at).map do |msg|
          { role: msg.role, content: msg.content }
        end

        # Get existing memory from workflow context
        workflow_context = conversation.workflow_context || {}
        memory = workflow_context.dig("state", "memory") || {}

        # Extract memory from recent messages (only every 3 messages to reduce API calls)
        messages_since_extraction = workflow_context.dig("state", "messages_since_extraction") || 0
        if messages_since_extraction >= 3 || memory.empty?
          # Extract key information from recent messages
          new_memory = Ai::MemoryBank.extract_memory(all_messages)
          memory = Ai::MemoryBank.merge_memory(memory, new_memory)
          context.set(:memory, memory)
          context.set(:messages_since_extraction, 0)
        else
          context.set(:messages_since_extraction, messages_since_extraction + 1)
        end

        # Build context prompt from memory (much smaller than all messages)
        memory_context = Ai::MemoryBank.build_context_prompt(memory)

        # Get system prompt from step or use default
        system_prompt = step["system_prompt"] || default_system_prompt

        # Add memory context to system prompt
        if memory_context.present?
          system_prompt += "\n\n#{memory_context}"
        end

        # Use only the last 2-3 messages for immediate context (very minimal!)
        recent_messages = all_messages.last(3)
        last_user_message = recent_messages.select { |m| m[:role] == "user" }.last&.dig(:content)
        return "I'm ready to help! What can I do for you?" unless last_user_message

        # Call AI Gateway with minimal message history (memory is in system prompt)
        # This dramatically reduces tokens: ~200-400 tokens instead of 1000+
        ai_response = Ai::AiGateway.call(
          instruction: last_user_message,
          system_prompt: system_prompt,
          context: {},
          message_history: recent_messages
        )

        # Return the AI response directly (WorkflowEngine will send it as assistant message)
        ai_response || "I'm sorry, I couldn't generate a response. Please try again."
      end

      private

      def default_system_prompt
        <<~PROMPT
          You are a helpful and friendly assistant for booking appointments and consultations.
          You should:
          - Be conversational and natural
          - Ask clarifying questions when needed
          - Remember information from the conversation
          - Help users book appointments by collecting: name, preferred date/time, and reason for visit
          - Be concise but friendly
          - Confirm details before finalizing bookings

          Respond naturally to the user's messages. Keep responses short and conversational.
        PROMPT
      end
    end
  end
end
