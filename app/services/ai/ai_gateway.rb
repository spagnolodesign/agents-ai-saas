module Ai
    class AiGateway
      def self.call(instruction:, system_prompt:, context:)
        api_key = Rails.application.credentials.openai&.api_key
        raise "OpenAI API key not configured in Rails credentials" unless api_key

        client = OpenAI::Client.new(access_token: api_key)

        # The context must not be sent as an assistant message.
        # It must be part of developer metadata.
        developer_prompt = "CONTEXT DATA:\n#{context.to_json}"

        response = client.chat(
          parameters: {
            model: "gpt-4o-mini",
            messages: [
              { role: "system", content: system_prompt },
              { role: "developer", content: developer_prompt },
              { role: "user", content: instruction }
            ],
            temperature: 0.2,
            max_tokens: 800,
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
