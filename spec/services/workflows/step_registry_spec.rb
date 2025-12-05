require "rails_helper"
require_relative "../../../app/services/workflows/step_registry"
require_relative "../../../app/services/workflows/steps/ask_step"
require_relative "../../../app/services/workflows/steps/ai_step"
require_relative "../../../app/services/workflows/steps/save_step"
require_relative "../../../app/services/workflows/steps/notify_step"
require_relative "../../../app/services/workflows/steps/calendar_sync_step"
require_relative "../../../app/services/workflows/steps/branch_step"
require_relative "../../../app/services/workflows/steps/wait_step"
require_relative "../../../app/services/workflows/steps/event_log_step"

RSpec.describe Workflows::StepRegistry do
  describe ".register" do
    it "registers a step type to a handler class" do
      test_class = Class.new

      described_class.register("test_step", test_class)

      expect(described_class.resolve("test_step")).to eq(test_class)
    end
  end

  describe ".resolve" do
    before do
      described_class.register("ask", Workflows::Steps::AskStep)
      described_class.register("ai", Workflows::Steps::AiStep)
      described_class.register("save", Workflows::Steps::SaveStep)
    end

    it "resolves 'ask' to AskStep" do
      expect(described_class.resolve("ask")).to eq(Workflows::Steps::AskStep)
    end

    it "resolves 'ai' to AiStep" do
      expect(described_class.resolve("ai")).to eq(Workflows::Steps::AiStep)
    end

    it "resolves 'save' to SaveStep" do
      expect(described_class.resolve("save")).to eq(Workflows::Steps::SaveStep)
    end

    it "returns nil for unknown step types" do
      expect(described_class.resolve("unknown")).to be_nil
    end
  end

  describe "built-in step registration" do
    it "automatically registers all built-in step types when class loads" do
      # Steps are registered immediately when StepRegistry class loads
      expect(described_class.resolve("ask")).to eq(Workflows::Steps::AskStep)
      expect(described_class.resolve("ai")).to eq(Workflows::Steps::AiStep)
      expect(described_class.resolve("save")).to eq(Workflows::Steps::SaveStep)
      expect(described_class.resolve("notify")).to eq(Workflows::Steps::NotifyStep)
      expect(described_class.resolve("calendar_sync")).to eq(Workflows::Steps::CalendarSyncStep)
      expect(described_class.resolve("branch")).to eq(Workflows::Steps::BranchStep)
      expect(described_class.resolve("wait")).to eq(Workflows::Steps::WaitStep)
      expect(described_class.resolve("event_log")).to eq(Workflows::Steps::EventLogStep)
    end
  end
end
