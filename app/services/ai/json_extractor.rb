module Ai
  # JsonExtractor parses structured JSON output from AI responses
  class JsonExtractor
    def self.extract(text)
      new(text).extract
    end

    def initialize(text)
      @text = text.to_s.strip
    end

    def extract
      # Try to find JSON in the text
      json_match = find_json_in_text

      return nil if json_match.nil?

      parsed = JSON.parse(json_match)
      parsed
    rescue JSON::ParserError => e
      Rails.logger.error("JSON EXTRACTION ERROR: #{e.message}")
      nil
    end

    private

    def find_json_in_text
      # Look for JSON object or array
      # Try to find content between { } or [ ]
      json_object_match = @text.match(/\{[\s\S]*\}/)
      return json_object_match[0] if json_object_match

      json_array_match = @text.match(/\[[\s\S]*\]/)
      return json_array_match[0] if json_array_match

      # If entire text is JSON, try parsing it
      JSON.parse(@text)
      @text
    rescue JSON::ParserError
      nil
    end
  end
end
