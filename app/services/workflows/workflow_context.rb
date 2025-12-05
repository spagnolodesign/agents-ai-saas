module Workflows
  # WorkflowContext stores state during workflow execution
  # It's a PORO (Plain Old Ruby Object) that holds:
  # - answers from user interactions
  # - temporary variables
  # - extracted booking data
  # - AI outputs
  # - step index
  # - customer reference
  class WorkflowContext
    attr_accessor :state, :current_step_index, :customer, :outputs, :errors

    def initialize(initial_state = {})
      @state = initial_state
      @current_step_index = 0
      @customer = nil
      @outputs = []
      @errors = []
    end

    def set(key, value)
      @state[key.to_s] = value
    end

    def get(key)
      @state[key.to_s]
    end

    def advance_step
      @current_step_index += 1
    end

    def halt!
      @state["halted"] = true
    end
  end
end
