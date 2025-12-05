namespace :api do
  namespace :chat do
    desc "Test Chat API endpoint with real GPT API (use USE_REAL_API=true)"
    task test: :environment do
      puts "=" * 80
      puts "CHAT API TEST - BOOKING REQUEST CONVERSATION"
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

        # Ensure Booking Workflow exists
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

        puts "✓ Brand: #{brand.name} (subdomain: #{brand.subdomain})"
        puts "✓ Workflow: #{workflow.name} (#{workflow.steps.count} steps)"
        puts

        # Simulate API requests (calling ConversationEngine directly like ChatController does)
        puts "=" * 80
        puts "SIMULATING API REQUESTS (POST /api/v1/chat)"
        puts "=" * 80
        puts

        # Set tenant context
        ActsAsTenant.current_tenant = brand

        # Conversation messages for booking request
        conversation_messages = [
          "Ciao, vorrei prenotare un appuntamento",
          "Mi chiamo Marco Rossi e vorrei una consulenza per la prossima settimana",
          "Perfetto, grazie mille!"
        ]

        conversation_id = nil

        conversation_messages.each_with_index do |user_message, index|
          puts "─" * 80
          puts "API Request #{index + 1} - POST /api/v1/chat"
          puts "─" * 80
          puts

          puts "👤 User Message: #{user_message}"
          if conversation_id
            puts "📋 Conversation ID: #{conversation_id}"
          end
          puts

          begin
            # Simulate ChatController logic (exactly as the controller does)
            message = user_message.to_s.strip

            if message.blank?
              puts "❌ Error: Message cannot be empty (HTTP 422)"
              next
            end

            brand_for_request = ActsAsTenant.current_tenant
            unless brand_for_request
              puts "❌ Error: Brand not resolved (HTTP 422)"
              next
            end

            # Find or create conversation (simulating controller logic)
            if conversation_id
              conversation = brand_for_request.conversations.find(conversation_id)
            else
              conversation = brand_for_request.conversations.create!(
                customer: nil,
                status: "active",
                workflow_context: {}
              )
            end

            # Run ConversationEngine (simulating controller logic)
            engine = ConversationEngine.new
            reply = engine.process(conversation: conversation, user_message: message)

            # Simulate JSON response (as ChatController returns)
            conversation_id = conversation.id
            halted = reply.nil?

            puts "🤖 Assistant Reply: #{reply || '[Waiting for user input - workflow halted]'}"
            puts "📊 API Response (JSON):"
            puts "   {"
            puts "     \"conversation_id\": #{conversation_id},"
            puts "     \"reply\": #{reply.inspect},"
            puts "     \"halted\": #{halted}"
            puts "   }"
            puts "   HTTP Status: 200"

            # Show workflow context
            conversation.reload
            context_data = conversation.workflow_context || {}
            if context_data.present?
              puts "   Workflow Step: #{context_data['current_step_index'] || 0}"
              puts "   Context Keys: #{context_data['state']&.keys&.join(', ') || 'none'}"
            end
          rescue => e
            puts "❌ Error: #{e.message}"
            puts "   HTTP Status: 500"
            puts e.backtrace.first(3).join("\n")
          end

          puts
        end

        # Show final conversation summary
        if conversation_id
          puts "=" * 80
          puts "FULL CONVERSATION HISTORY"
          puts "=" * 80
          puts

          conversation = Conversation.find(conversation_id)
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
          puts "Customer: #{conversation.customer ? conversation.customer.name : 'Anonymous'}"
          puts "Workflow context persisted: #{conversation.workflow_context.present? ? 'Yes' : 'No'}"
          puts
        end

        puts "=" * 80
        puts "✅ API CHAT TEST COMPLETED!"
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
end
