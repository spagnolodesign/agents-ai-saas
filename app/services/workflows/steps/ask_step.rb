module Workflows
  module Steps
    class AskStep < BaseStep
      def call
        context.set(:last_question, step["question"])
        :halt
      end
    end
  end
end
