module Workflows
  module Steps
    class ResponseStep < BaseStep
      # ResponseStep returns a message to the ConversationEngine.
      # When a step returns a String, WorkflowEngine HALTS
      # and sends that string as an assistant message.
      #
      # Example step:
      # {
      #   "type": "response",
      #   "message": "Ciao {{context.name}}, ho registrato i tuoi dati."
      # }
      def call
        template = step["message"] || ""

        render_with_context(template)
      end

      private

      # Replace placeholders like:
      # {{context.name}}
      # {{context.booking.date}}
      #
      def render_with_context(template)
        result = template.dup

        template.scan(/\{\{context\.(.*?)\}\}/).each do |match|
          path = match.first.split(".")
          key = path.shift
          value = context.get(key)

          path.each { |k| value = value.is_a?(Hash) ? value[k] : nil }

          result.gsub!("{{context.#{match.first}}}", value.to_s)
        end

        result
      end
    end
  end
end

