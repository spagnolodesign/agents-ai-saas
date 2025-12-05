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
      if initial_state.is_a?(Hash) && initial_state.key?("state")
        # Restore from persisted hash
        @state = initial_state["state"] || {}
        @current_step_index = initial_state["current_step_index"] || 0
        @customer = nil # Will be set separately
        @outputs = initial_state["outputs"] || []
        @errors = initial_state["errors"] || []
      else
        # Initialize from state hash directly
        @state = initial_state.is_a?(Hash) ? initial_state : {}
        @current_step_index = 0
        @customer = nil
        @outputs = []
        @errors = []
      end
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

    def to_h
      {
        "state" => @state,
        "current_step_index" => @current_step_index,
        "errors" => @errors,
        "outputs" => @outputs
      }
    end
  end
end
