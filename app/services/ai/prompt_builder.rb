module Ai
    class PromptBuilder
      # Build the final system prompt by merging:
      # - global template
      # - brand-level template overrides
      # - workflow context variables
      #
      # Usage:
      #   Ai::PromptBuilder.build(template:, brand_template:, context:)
      #
      def self.build(template:, brand_template:, context:)
        return default_prompt unless template

        prompt = template.base_prompt.dup

        # Apply brand overrides if present
        if brand_template&.overrides&.dig("system_prompt")
          prompt += "\n\n" + brand_template.overrides["system_prompt"]
        end

        # Inject context variables like {{context.key}} or nested {{context.key.subkey}}
        prompt = inject_context_variables(prompt, context)

        prompt
      end

      def self.default_prompt
        <<~PROMPT
        You are an AI assistant for a business. Always respond clearly and concisely.
        PROMPT
      end


      private

      # Handles placeholders like:
      # {{context.name}}
      # {{context.booking.date}}
      def self.inject_context_variables(prompt, context)
        prompt.gsub(/\{\{context\.(.*?)\}\}/) do
          path = Regexp.last_match(1).split(".")
          resolve_context_path(context, path)
        end
      end


      def self.resolve_context_path(context, path)
        data = context.get(path.shift)

        path.each do |key|
          data = data.is_a?(Hash) ? data[key] : nil
        end

        data.to_s
      end
    end
end
