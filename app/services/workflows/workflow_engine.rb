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
      # Load steps from workflow
      # Iterate through steps
      # Execute each step
      # Update context
      # Stop if step returns :halt
    end

    def execute_step(step)
      # Resolve handler for step
      # Execute handler
      # Return result
    end

    def handler_for(step)
      # Resolve step type to handler class via StepRegistry
    end
  end
end
