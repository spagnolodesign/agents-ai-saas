module Workflows
  class StepRegistry
    @registry = {}

    class << self
      def register(type, klass)
        @registry[type.to_s] = klass
      end

      def resolve(type)
        @registry[type.to_s]
      end
    end

    register("ask", Workflows::Steps::AskStep)
    register("ai", Workflows::Steps::AiStep)
    register("save", Workflows::Steps::SaveStep)
    register("notify", Workflows::Steps::NotifyStep)
    register("calendar_sync", Workflows::Steps::CalendarSyncStep)
    register("branch", Workflows::Steps::BranchStep)
    register("wait", Workflows::Steps::WaitStep)
    register("event_log", Workflows::Steps::EventLogStep)
  end
end
