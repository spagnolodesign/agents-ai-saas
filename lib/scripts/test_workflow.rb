# Rails console script to test the Workflow Engine
# Usage: rails runner lib/scripts/test_workflow.rb
# Or copy-paste into rails console

# Ensure AiGateway is loaded
require_relative "../../app/services/ai/ai_gateway"

puts "=" * 80
puts "Testing Workflow Engine"
puts "=" * 80
puts

# Create fake data
puts "📦 Creating fake data..."
brand = Brand.find_or_create_by!(subdomain: "testbrand") do |b|
  b.name = "Test Brand"
end

customer = Customer.find_or_create_by!(brand: brand, email: "test@example.com") do |c|
  c.name = "Test Customer"
  c.phone = "123-456-7890"
end

# Create a workflow with steps
workflow = Workflow.find_or_create_by!(brand: brand, name: "Test Workflow") do |w|
  w.enabled = true
  w.steps = [
    {
      "type" => "ask",
      "question" => "What is your name?",
      "variable" => "name"
    },
    {
      "type" => "ai",
      "instruction" => "Extract the customer's name from the conversation",
      "variable" => "extracted_name"
    },
    {
      "type" => "save",
      "model" => "booking",
      "fields" => {
        "service_type" => "{{context.name}} consultation",
        "date" => "2025-12-25",
        "status" => "pending"
      }
    }
  ]
end

puts "✓ Brand: #{brand.name} (#{brand.subdomain})"
puts "✓ Customer: #{customer.name} (#{customer.email})"
puts "✓ Workflow: #{workflow.name} (#{workflow.steps.count} steps)"
puts

# Create workflow context
puts "🔧 Creating WorkflowContext..."
context = Workflows::WorkflowContext.new
context.customer = customer
ActsAsTenant.current_tenant = brand
puts "✓ Context created with customer: #{context.customer.name}"
puts

# Test StepRegistry
puts "📋 Testing StepRegistry..."
ask_step_class = Workflows::StepRegistry.resolve("ask")
ai_step_class = Workflows::StepRegistry.resolve("ai")
save_step_class = Workflows::StepRegistry.resolve("save")
puts "✓ AskStep: #{ask_step_class}"
puts "✓ AiStep: #{ai_step_class}"
puts "✓ SaveStep: #{save_step_class}"
puts

# Test individual steps
puts "=" * 80
puts "Testing Individual Steps"
puts "=" * 80
puts

# Test AskStep
puts "1️⃣ Testing AskStep..."
ask_step_data = workflow.steps[0]
engine = Object.new # Simple object for testing
ask_step = Workflows::Steps::AskStep.new(
  engine: engine,
  context: context,
  step: ask_step_data
)
result = ask_step.call
puts "   Question saved: #{context.get(:last_question)}"
puts "   Result: #{result.inspect}"
puts "   ✓ AskStep completed (halted workflow)"
puts

# Simulate user response
puts "💬 Simulating user response..."
context.set("name", "John Doe")
puts "   User answered: #{context.get('name')}"
puts

# Test AiStep
puts "2️⃣ Testing AiStep..."
ai_step_data = workflow.steps[1]
ai_step = Workflows::Steps::AiStep.new(
  engine: engine,
  context: context,
  step: ai_step_data
)
result = ai_step.call
puts "   AI extracted: #{context.get('extracted_name')}"
puts "   Result: #{result.inspect}"
puts "   ✓ AiStep completed"
puts

# Test SaveStep
puts "3️⃣ Testing SaveStep..."
save_step_data = workflow.steps[2]
save_step = Workflows::Steps::SaveStep.new(
  engine: engine,
  context: context,
  step: save_step_data
)
booking_count_before = Booking.count
result = save_step.call
booking_count_after = Booking.count
puts "   Bookings before: #{booking_count_before}"
puts "   Bookings after: #{booking_count_after}"
if booking_count_after > booking_count_before
  booking = Booking.last
  puts "   ✓ Booking created:"
  puts "     - ID: #{booking.id}"
  puts "     - Service Type: #{booking.service_type}"
  puts "     - Date: #{booking.date}"
  puts "     - Status: #{booking.status}"
  puts "     - Brand: #{booking.brand.name}"
  puts "     - Customer: #{booking.customer.name}"
  puts "   Saved record ID in context: #{context.get(:last_saved_record_id)}"
end
puts "   Result: #{result.inspect}"
puts "   ✓ SaveStep completed"
puts

# Show final context state
puts "=" * 80
puts "Final Context State"
puts "=" * 80
puts "State keys: #{context.state.keys.join(', ')}"
puts "Current step index: #{context.current_step_index}"
puts "Customer: #{context.customer.name}"
puts "Errors: #{context.errors.empty? ? 'None' : context.errors.join(', ')}"
puts

puts "=" * 80
puts "✅ Workflow test completed successfully!"
puts "=" * 80

