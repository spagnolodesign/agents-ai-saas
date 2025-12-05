module Ai
  # ConversationSummarizer creates summaries of conversation history
  # to reduce token usage while maintaining context
  class ConversationSummarizer
    # Summarize a list of messages (already filtered)
    # Returns a concise summary string
    def self.summarize_messages(messages)
      return nil if messages.nil? || messages.empty?

      # Build summary prompt - limit message content length to reduce tokens
      conversation_text = messages.map do |msg|
        content = msg[:content]
        # Truncate very long messages to max 200 chars
        content = content[0..200] + "..." if content.length > 200
        "#{msg[:role] == 'user' ? 'User' : 'Assistant'}: #{content}"
      end.join("\n")

      # Limit total conversation text to ~1000 tokens worth (~750 words)
      if conversation_text.length > 3000
        conversation_text = conversation_text[-3000..]
      end

      summary_prompt = <<~PROMPT
        Summarize this conversation concisely (2-3 sentences max). Focus on:
        - Key info (names, dates, preferences)
        - Important decisions
        - Current status

        Conversation:
        #{conversation_text}

        Summary:
      PROMPT

      # Call AI to generate summary
      api_key = Rails.application.credentials.openai&.api_key
      return nil unless api_key

      client = OpenAI::Client.new(access_token: api_key)

      response = client.chat(
        parameters: {
          model: "gpt-4o-mini",
          messages: [
            { role: "system", content: "Create concise conversation summaries (2-3 sentences max)." },
            { role: "user", content: summary_prompt }
          ],
          temperature: 0.3,
          max_tokens: 100 # Reduced from 150
        }
      )

      response.dig("choices", 0, "message", "content")&.strip
    rescue => e
      Rails.logger.error("Summarization error: #{e.message}")
      nil
    end
  end
end
