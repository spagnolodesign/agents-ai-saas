module Workflows
  # WorkflowEngine is responsible for:
  # - loading steps from a Workflow record
  # - iterating steps
  # - resolving handlers via StepRegistry
  # - executing steps sequentially
  # - updating WorkflowContext
  # - stopping execution if a step returns :halt
  class WorkflowEngine
    attr_reader :workflow, :context

    def initialize(workflow:, context:)
      @workflow = workflow
      @context = context
    end

    def execute
      steps = workflow.steps || []
      return nil if steps.empty?

      # Start from current step index (to resume from where we left off)
      start_index = context.current_step_index || 0

      # If workflow already completed (step index >= steps length), reset or return nil
      if start_index >= steps.length
        return nil
      end

      # If we're resuming and last question was already asked, skip the AskStep
      if start_index == 0 && context.get(:last_question).present?
        start_index = 1
        context.current_step_index = 1
      end

      # Iterate through steps starting from current position
      steps[start_index..].each_with_index do |step_data, relative_index|
        result = execute_step(step_data)

        # If step returns a String (e.g., ResponseStep, ChatStep), return it as reply
        if result.is_a?(String)
          step_type = step_data["type"] || step_data[:type]
          # For ChatStep, don't advance - keep at same step for next message
          if step_type == "chat"
            # Keep current step index so next message goes through ChatStep again
            return result
          else
            # For other steps (ResponseStep), mark as completed
            context.current_step_index = start_index + relative_index
            return result
          end
        end

        # If step returns :halt (e.g., AskStep), return the question that was asked
        # Don't advance step index - waiting for user response
        if result == :halt
          question = context.get(:last_question)
          return question if question.present?
          return nil
        end

        # Advance to next step for steps that return nil (continue execution)
        context.current_step_index = start_index + relative_index + 1
      end

      # No reply generated, workflow completed
      nil
    end

    def execute_step(step)
      handler_class = handler_for(step)
      return nil unless handler_class

      handler = handler_class.new(
        engine: self,
        context: context,
        step: step
      )

      handler.call
    end

    def handler_for(step)
      step_type = step["type"] || step[:type]
      StepRegistry.resolve(step_type)
    end
  end
end
