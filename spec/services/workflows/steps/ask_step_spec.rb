require "rails_helper"
require_relative "../../../../app/services/workflows/steps/ask_step"
require_relative "../../../../app/services/workflows/workflow_context"

RSpec.describe Workflows::Steps::AskStep do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:context) { Workflows::WorkflowContext.new }
  let(:engine) { double("WorkflowEngine") }
  let(:step) { { "type" => "ask", "question" => "What is your name?", "variable" => "name" } }

  before do
    context.customer = customer
  end

  describe "#call" do
    it "saves the question to context as :last_question" do
      ask_step = described_class.new(engine: engine, context: context, step: step)

      result = ask_step.call

      expect(context.get(:last_question)).to eq("What is your name?")
      expect(result).to eq(:halt)
    end

    it "returns :halt to stop workflow execution" do
      ask_step = described_class.new(engine: engine, context: context, step: step)

      result = ask_step.call

      expect(result).to eq(:halt)
    end
  end
end
