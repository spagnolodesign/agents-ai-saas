namespace :workflow do
  desc "Test workflow system with mocked AI"
  task test: :environment do
    puts "=" * 80
    puts "WORKFLOW SYSTEM TEST"
    puts "=" * 80
    puts

    # Store original AiGateway method
    original_ai_gateway = Ai::AiGateway.method(:call)

    begin
      # Mock AiGateway to return structured JSON
      Ai::AiGateway.define_singleton_method(:call) do |instruction:, system_prompt:, context:|
        {
          "reply" => "Hello!",
          "data" => { "name" => "John" }
        }.to_json
      end

      puts "📦 Creating test data..."
      brand = Brand.find_or_create_by!(subdomain: "testbrand") do |b|
        b.name = "Test Brand"
      end

      customer = Customer.find_or_create_by!(brand: brand, email: "test@example.com") do |c|
        c.name = "Test Customer"
        c.phone = "123-456-7890"
      end

      # Create a workflow with 3 steps
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
            "model" => "lead",
            "fields" => {
              "form_type" => "contact",
              "status" => "new"
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
      puts "EXECUTING WORKFLOW STEPS"
      puts "=" * 80
      puts

      engine = Object.new

      # Step 1: AskStep
      puts "1️⃣ Executing AskStep..."
      ask_step_data = workflow.steps[0]
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

      # Step 2: AiStep
      puts "2️⃣ Executing AiStep..."
      ai_step_data = workflow.steps[1]
      ai_step = Workflows::Steps::AiStep.new(
        engine: engine,
        context: context,
        step: ai_step_data
      )
      result = ai_step.call
      puts "   AI raw output: #{context.get('extracted_name_raw')}"
      puts "   AI structured output: #{context.get('extracted_name').inspect}"
      puts "   Result: #{result.inspect}"
      puts "   ✓ AiStep completed"
      puts

      # Step 3: SaveStep
      puts "3️⃣ Executing SaveStep..."
      save_step_data = workflow.steps[2]
      save_step = Workflows::Steps::SaveStep.new(
        engine: engine,
        context: context,
        step: save_step_data
      )
      lead_count_before = Lead.count
      result = save_step.call
      lead_count_after = Lead.count
      puts "   Leads before: #{lead_count_before}"
      puts "   Leads after: #{lead_count_after}"
      if lead_count_after > lead_count_before
        lead = Lead.last
        puts "   ✓ Lead created:"
        puts "     - ID: #{lead.id}"
        puts "     - Form Type: #{lead.form_type}"
        puts "     - Status: #{lead.status}"
        puts "     - Brand: #{lead.brand.name}"
        puts "     - Customer: #{lead.customer.name}"
        puts "   Saved record ID in context: #{context.get(:last_saved_record_id)}"
      end
      puts "   Result: #{result.inspect}"
      puts "   ✓ SaveStep completed"
      puts

      # Show final context state
      puts "=" * 80
      puts "FINAL CONTEXT STATE"
      puts "=" * 80
      puts "State keys: #{context.state.keys.join(', ')}"
      puts "Current step index: #{context.current_step_index}"
      puts "Customer: #{context.customer.name}"
      puts "Errors: #{context.errors.empty? ? 'None' : context.errors.join(', ')}"
      puts

      # Show key outputs
      puts "=" * 80
      puts "KEY OUTPUTS"
      puts "=" * 80
      puts "Last question: #{context.get(:last_question)}"
      puts "AI structured output: #{context.get('extracted_name').inspect}"
      puts "Last saved record ID: #{context.get(:last_saved_record_id)}"
      puts

      puts "=" * 80
      puts "✅ WORKFLOW TEST COMPLETED SUCCESSFULLY!"
      puts "=" * 80

    ensure
      # Restore original AiGateway method
      Ai::AiGateway.define_singleton_method(:call, original_ai_gateway)
      puts
      puts "✓ AiGateway method restored"
    end
  end
end
