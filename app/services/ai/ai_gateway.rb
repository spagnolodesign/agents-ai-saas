module Ai
  class AiGateway
    # Call AI with instruction and context
    # If message_history is provided, use it for conversational chat
    def self.call(instruction:, system_prompt:, context:, message_history: nil)
      api_key = Rails.application.credentials.openai&.api_key
      raise "OpenAI API key not configured in Rails credentials" unless api_key

      client = OpenAI::Client.new(access_token: api_key)

      # Build messages array
      messages = []

      # Add system prompt
      messages << { role: "system", content: system_prompt }

      # If message_history is provided, use it for conversational chat
      if message_history&.any?
        # Add conversation history (excluding the last user message which is in instruction)
        message_history[0..-2].each do |msg|
          # Map roles: user -> user, assistant -> assistant, system -> system
          role = msg[:role] == "assistant" ? "assistant" : "user"
          messages << { role: role, content: msg[:content] }
        end
        # Add the current user message
        messages << { role: "user", content: instruction }
      else
        # Original behavior: use context as developer metadata
        developer_prompt = "CONTEXT DATA:\n#{context.to_json}"
        messages << { role: "developer", content: developer_prompt }
        messages << { role: "user", content: instruction }
      end

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: messages,
          temperature: 0.7, # Higher temperature for more natural conversation
          max_tokens: 500,
          stop: [ "</json>", "</end>" ]
        }
      )

      response.dig("choices", 0, "message", "content")
    rescue => e
      Rails.logger.error("AI ERROR: #{e.message}")
      nil
    end
  end
end
