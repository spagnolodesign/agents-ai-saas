module Workflows
  module Steps
    class BaseStep
      attr_reader :engine, :context, :step

      def initialize(engine:, context:, step:)
        @engine = engine
        @context = context
        @step = step
      end

      def call
        raise NotImplementedError
      end
    end
  end
end
