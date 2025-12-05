require "rails_helper"
require_relative "../../../../app/services/workflows/steps/ai_step"
require_relative "../../../../app/services/workflows/workflow_context"
require_relative "../../../../app/services/ai/ai_gateway"

RSpec.describe Workflows::Steps::AiStep do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:context) { Workflows::WorkflowContext.new }
  let(:engine) { double("WorkflowEngine") }
  let(:step) { { "type" => "ai", "instruction" => "Extract the name from the conversation", "variable" => "extracted_name" } }

  before do
    context.customer = customer
  end

  describe "#call" do
    it "calls AiGateway with instruction and context" do
      allow(AiGateway).to receive(:call).and_return("John Doe")

      ai_step = described_class.new(engine: engine, context: context, step: step)

      ai_step.call

      expect(AiGateway).to have_received(:call).with(
        instruction: "Extract the name from the conversation",
        context: context.state
      )
    end

    it "stores the AI output in context under the specified variable" do
      allow(AiGateway).to receive(:call).and_return("John Doe")

      ai_step = described_class.new(engine: engine, context: context, step: step)

      ai_step.call

      expect(context.get("extracted_name")).to eq("John Doe")
    end

    it "returns nil to continue workflow execution" do
      allow(AiGateway).to receive(:call).and_return("John Doe")

      ai_step = described_class.new(engine: engine, context: context, step: step)

      result = ai_step.call

      expect(result).to be_nil
    end
  end
end
