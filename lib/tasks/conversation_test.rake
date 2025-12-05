namespace :conversation do
  desc "Test ConversationEngine with real GPT API (use USE_REAL_API=true)"
  task test: :environment do
    puts "=" * 80
    puts "CONVERSATION ENGINE TEST"
    puts "=" * 80
    puts

    use_real_api = ENV["USE_REAL_API"] == "true"

    if use_real_api
      puts "⚠️  WARNING: Using REAL GPT API - this will incur costs!"
      puts "   Make sure OPENAI_API_KEY is configured in Rails credentials"
      puts "   Press Ctrl+C within 5 seconds to cancel..."
      sleep 5
      puts
    else
      puts "ℹ️  Using MOCKED AI (set USE_REAL_API=true to use real GPT API)"
      puts
    end

    # Store original AiGateway method
    original_ai_gateway = Ai::AiGateway.method(:call)

    begin
      unless use_real_api
        # Mock AiGateway to return structured JSON matching the workflow
        Ai::AiGateway.define_singleton_method(:call) do |instruction:, system_prompt:, context:|
          {
            "reply" => "Ho estratto le informazioni dalla conversazione.",
            "data" => {
              "name" => "Marco Rossi",
              "intent" => "booking",
              "preferred_date" => "2025-12-20"
            }
          }.to_json
        end
      end

      # Setup test data
      puts "📦 Setting up test data..."
      brand = Brand.find_or_create_by!(subdomain: "testbrand") do |b|
        b.name = "Test Brand"
      end

      customer = Customer.find_or_create_by!(brand: brand, email: "test@example.com") do |c|
        c.name = "Test Customer"
        c.phone = "123-456-7890"
      end

      # Create a booking workflow for AI agent
      workflow = Workflow.find_or_create_by!(brand: brand, name: "Booking Workflow") do |w|
        w.enabled = true
        w.steps = [
          {
            "type" => "ask",
            "question" => "Ciao! Come posso aiutarti oggi? Vuoi prenotare un appuntamento?",
            "variable" => "greeting_response"
          },
          {
            "type" => "ai",
            "instruction" => "Extract the customer's name, intent (booking/consultation), and preferred date from the conversation. Return JSON with 'name', 'intent', and 'preferred_date' fields.",
            "variable" => "extracted_info"
          },
          {
            "type" => "save",
            "model" => "lead",
            "fields" => {
              "form_type" => "booking_request",
              "status" => "new"
            }
          },
          {
            "type" => "response",
            "message" => "Perfetto {{context.extracted_info.data.name}}! Ho registrato la tua richiesta per {{context.extracted_info.data.preferred_date}}. Ti contatteremo presto per confermare l'appuntamento."
          }
        ]
      end

      puts "✓ Brand: #{brand.name}"
      puts "✓ Customer: #{customer.name}"
      puts "✓ Workflow: #{workflow.name}"
      puts

      # Create conversation (always start fresh for testing)
      puts "💬 Creating conversation..."
      # Delete existing test conversation to start fresh
      Conversation.where(brand: brand, customer: customer, status: "active").destroy_all
      conversation = Conversation.create!(
        brand: brand,
        customer: customer,
        status: "active",
        workflow_context: {}
      )

      puts "✓ Conversation ID: #{conversation.id}"
      puts

      # Initialize ConversationEngine
      engine = ConversationEngine.new

      # Real conversation flow for booking AI agent
      test_messages = [
        "Ciao, vorrei prenotare un appuntamento",
        "Mi chiamo Marco Rossi e vorrei una consulenza per la prossima settimana",
        "Perfetto, grazie mille!"
      ]

      puts "=" * 80
      puts "CONVERSATION LOG"
      puts "=" * 80
      puts

      test_messages.each_with_index do |user_message, index|
        puts "─" * 80
        puts "Turn #{index + 1}"
        puts "─" * 80
        puts
        puts "👤 User: #{user_message}"
        puts

        begin
          reply = engine.process(conversation: conversation, user_message: user_message)

          if reply.present?
            puts "🤖 Assistant: #{reply}"
          else
            puts "🤖 Assistant: [Waiting for user input - workflow halted]"
          end
        rescue => e
          puts "❌ Error: #{e.message}"
          puts e.backtrace.first(3).join("\n")
        end

        puts

        # Show workflow context state
        conversation.reload
        context_data = conversation.workflow_context || {}
        if context_data.present?
          puts "📊 Workflow Context:"
          puts "   State keys: #{context_data['state']&.keys&.join(', ') || 'none'}"
          puts "   Current step: #{context_data['current_step_index'] || 0}"
          puts "   Errors: #{context_data['errors']&.any? ? context_data['errors'].join(', ') : 'none'}"
          puts
        end

        # Show message count
        message_count = conversation.messages.count
        puts "💾 Messages in conversation: #{message_count}"
        puts
      end

      puts "=" * 80
      puts "FULL CONVERSATION HISTORY"
      puts "=" * 80
      puts

      conversation.reload
      conversation.messages.order(:created_at).each do |message|
        role_icon = message.role == "user" ? "👤" : "🤖"
        puts "#{role_icon} [#{message.role.upcase}] #{message.created_at.strftime('%H:%M:%S')}"
        puts "   #{message.content}"
        puts
      end

      puts "=" * 80
      puts "CONVERSATION SUMMARY"
      puts "=" * 80
      puts "Conversation ID: #{conversation.id}"
      puts "Total messages: #{conversation.messages.count}"
      puts "Status: #{conversation.status}"
      puts "Workflow context persisted: #{conversation.workflow_context.present? ? 'Yes' : 'No'}"
      puts

      puts "=" * 80
      puts "✅ CONVERSATION TEST COMPLETED!"
      puts "=" * 80

    ensure
      # Restore original AiGateway method
      unless use_real_api
        Ai::AiGateway.define_singleton_method(:call, original_ai_gateway)
        puts
        puts "✓ AiGateway method restored"
      end
    end
  end
end
