module Ai
  # MemoryBank maintains structured memory of conversation
  # Instead of sending all messages, we extract and store only key information
  class MemoryBank
    def self.extract_memory(messages)
      # Extract key information from recent messages using AI
      # This is much more efficient than sending all messages
      return {} if messages.empty?

      # Use only last 10 messages for extraction (to limit token cost)
      recent_messages = messages.last(10)
      conversation_text = recent_messages.map do |msg|
        "#{msg[:role] == 'user' ? 'User' : 'Assistant'}: #{msg[:content]}"
      end.join("\n")

      extraction_prompt = <<~PROMPT
        Extract ONLY key information from this conversation as JSON:
        {
          "customer_name": "name if mentioned",
          "preferred_date": "date if mentioned",
          "preferred_time": "time if mentioned",
          "service_type": "service/consultation type if mentioned",
          "status": "current booking status (e.g., 'collecting_info', 'confirmed', etc.)",
          "notes": "any important notes or preferences"
        }

        Only include fields that were actually mentioned. Return JSON only, no other text.

        Conversation:
        #{conversation_text}
      PROMPT

      api_key = Rails.application.credentials.openai&.api_key
      return {} unless api_key

      client = OpenAI::Client.new(access_token: api_key)

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            { role: "system", content: "Extract structured information from conversations. Return only valid JSON." },
            { role: "user", content: extraction_prompt }
          ],
          temperature: 0.1,
          max_tokens: 200,
          response_format: { type: "json_object" }
        }
      )

      json_text = response.dig("choices", 0, "message", "content")
      return {} unless json_text

      JSON.parse(json_text)
    rescue => e
      Rails.logger.error("Memory extraction error: #{e.message}")
      {}
    end

    def self.merge_memory(old_memory, new_extraction)
      # Merge new extraction into existing memory, updating only changed fields
      merged = old_memory.dup
      new_extraction.each do |key, value|
        # Only update if value is present and meaningful
        if value.present? && value != "null" && value != ""
          merged[key] = value
        end
      end
      merged
    end

    def self.build_context_prompt(memory)
      return "" if memory.empty?

      parts = []
      parts << "Customer information:" if memory["customer_name"].present?
      parts << "- Name: #{memory['customer_name']}" if memory["customer_name"].present?
      parts << "- Preferred date: #{memory['preferred_date']}" if memory["preferred_date"].present?
      parts << "- Preferred time: #{memory['preferred_time']}" if memory["preferred_time"].present?
      parts << "- Service type: #{memory['service_type']}" if memory["service_type"].present?
      parts << "- Status: #{memory['status']}" if memory["status"].present?
      parts << "- Notes: #{memory['notes']}" if memory["notes"].present?

      parts.join("\n")
    end
  end
end
