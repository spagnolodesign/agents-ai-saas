# Copy-paste this into Rails console (rails c)
# Or run: rails runner lib/scripts/test_workflow_console.rb

# Ensure AiGateway is loaded
require_relative "../../app/services/ai/ai_gateway"

# Setup
brand = Brand.find_or_create_by!(subdomain: "testbrand") { |b| b.name = "Test Brand" }
customer = Customer.find_or_create_by!(brand: brand, email: "test@example.com") { |c| c.name = "Test Customer"; c.phone = "123-456-7890" }

workflow = Workflow.find_or_create_by!(brand: brand, name: "Test Workflow") do |w|
  w.enabled = true
  w.steps = [
    { "type" => "ask", "question" => "What is your name?", "variable" => "name" },
    { "type" => "ai", "instruction" => "Extract the customer's name", "variable" => "extracted_name" },
    { "type" => "save", "model" => "booking", "fields" => { "service_type" => "{{context.name}} consultation", "date" => "2025-12-25", "status" => "pending" } }
  ]
end

# Create context
context = Workflows::WorkflowContext.new
context.customer = customer
ActsAsTenant.current_tenant = brand

# Test StepRegistry
puts "StepRegistry resolves:"
puts "  ask: #{Workflows::StepRegistry.resolve('ask')}"
puts "  ai: #{Workflows::StepRegistry.resolve('ai')}"
puts "  save: #{Workflows::StepRegistry.resolve('save')}"
puts

# Test AskStep
puts "Testing AskStep..."
engine = Object.new
ask_step = Workflows::Steps::AskStep.new(engine: engine, context: context, step: workflow.steps[0])
result = ask_step.call
puts "  Question: #{context.get(:last_question)}"
puts "  Result: #{result}"
puts

# Simulate user response
context.set("name", "John Doe")
puts "User answered: #{context.get('name')}"
puts

# Test AiStep
puts "Testing AiStep..."
ai_step = Workflows::Steps::AiStep.new(engine: engine, context: context, step: workflow.steps[1])
ai_step.call
puts "  AI output: #{context.get('extracted_name')}"
puts

# Test SaveStep
puts "Testing SaveStep..."
save_step = Workflows::Steps::SaveStep.new(engine: engine, context: context, step: workflow.steps[2])
save_step.call
booking = Booking.last
puts "  Created booking:"
puts "    ID: #{booking.id}"
puts "    Service: #{booking.service_type}"
puts "    Date: #{booking.date}"
puts "    Status: #{booking.status}"
puts "    Saved ID in context: #{context.get(:last_saved_record_id)}"
puts

puts "Context state: #{context.state.keys.join(', ')}"
puts "✅ Done!"

