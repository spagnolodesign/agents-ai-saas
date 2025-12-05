require "rails_helper"
require_relative "../../../../app/services/workflows/steps/save_step"
require_relative "../../../../app/services/workflows/workflow_context"

RSpec.describe Workflows::Steps::SaveStep do
  let(:brand) { create(:brand) }
  let(:customer) { create(:customer, brand: brand) }
  let(:context) { Workflows::WorkflowContext.new }
  let(:engine) { double("WorkflowEngine") }

  before do
    context.customer = customer
    ActsAsTenant.current_tenant = brand
  end

  describe "#call" do
    context "when saving a Booking" do
      let(:step) do
        {
          "type" => "save",
          "model" => "booking",
          "fields" => {
            "service_type" => "consultation",
            "date" => "2025-12-15",
            "status" => "pending"
          }
        }
      end

      it "creates a Booking record" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        expect { save_step.call }.to change { Booking.count }.by(1)
      end

      it "creates the booking under the current tenant" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        save_step.call

        booking = Booking.last
        expect(booking.brand).to eq(brand)
        expect(booking.customer).to eq(customer)
      end

      it "substitutes {{context.key}} placeholders in field values" do
        context.set("name", "John Doe")
        context.set("date", "2025-12-20")

        step_with_placeholders = {
          "type" => "save",
          "model" => "booking",
          "fields" => {
            "service_type" => "{{context.name}} consultation",
            "date" => "{{context.date}}",
            "status" => "pending"
          }
        }

        save_step = described_class.new(engine: engine, context: context, step: step_with_placeholders)

        save_step.call

        booking = Booking.last
        expect(booking.service_type).to eq("John Doe consultation")
        expect(booking.date.to_s).to eq("2025-12-20")
      end

      it "substitutes nested {{context.key.nested.path}} placeholders" do
        context.set("motivation", { "reply" => "I want to learn more" })
        context.set("extracted_name", { "data" => { "first_name" => "Jane", "last_name" => "Smith" } })

        step_with_nested_placeholders = {
          "type" => "save",
          "model" => "booking",
          "fields" => {
            "service_type" => "consultation",
            "notes" => "Motivation: {{context.motivation.reply}}, Name: {{context.extracted_name.data.first_name}}",
            "date" => "2025-12-25",
            "status" => "pending"
          }
        }

        save_step = described_class.new(engine: engine, context: context, step: step_with_nested_placeholders)

        save_step.call

        booking = Booking.last
        expect(booking.notes).to eq("Motivation: I want to learn more, Name: Jane")
      end

      it "stores the saved record ID in context as :last_saved_record_id" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        save_step.call

        booking = Booking.last
        expect(context.get(:last_saved_record_id)).to eq(booking.id)
      end
    end

    context "when saving a Lead" do
      let(:step) do
        {
          "type" => "save",
          "model" => "lead",
          "fields" => {
            "form_type" => "contact",
            "status" => "new"
          }
        }
      end

      it "creates a Lead record" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        expect { save_step.call }.to change { Lead.count }.by(1)
      end

      it "creates the lead under the current tenant" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        save_step.call

        lead = Lead.last
        expect(lead.brand).to eq(brand)
        expect(lead.customer).to eq(customer)
      end

      it "stores the saved record ID in context as :last_saved_record_id" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        save_step.call

        lead = Lead.last
        expect(context.get(:last_saved_record_id)).to eq(lead.id)
      end
    end

    context "when model is unknown" do
      let(:step) do
        {
          "type" => "save",
          "model" => "unknown_model",
          "fields" => {}
        }
      end

      it "adds an error to context and does not create a record" do
        save_step = described_class.new(engine: engine, context: context, step: step)

        expect { save_step.call }.not_to change { Booking.count }
        expect(context.errors).to include("Unknown model: unknown_model")
      end
    end
  end
end
