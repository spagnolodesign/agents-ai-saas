namespace :workflow do
  desc "Setup Chat Workflow for natural conversation"
  task setup_chat: :environment do
    puts "=" * 80
    puts "SETTING UP CHAT WORKFLOW"
    puts "=" * 80
    puts

    # Find or create test brand
    brand = Brand.find_or_create_by!(subdomain: "testbrand") do |b|
      b.name = "Test Brand"
    end

    puts "✓ Brand: #{brand.name} (subdomain: #{brand.subdomain})"
    puts

    # Create Chat Workflow for natural conversation
    workflow = Workflow.find_or_create_by!(brand: brand, name: "Chat Workflow") do |w|
      w.enabled = true
      w.steps = [
        {
          "type" => "chat",
          "system_prompt" => <<~PROMPT
            You are a helpful and friendly assistant for booking appointments and consultations.
            
            Your role:
            - Be conversational and natural
            - Ask clarifying questions when needed
            - Remember information from the conversation
            - Help users book appointments by collecting: name, preferred date/time, and reason for visit
            - Be concise but friendly
            - Confirm details before finalizing bookings
            
            Guidelines:
            - Keep responses short (1-2 sentences)
            - Be warm and professional
            - If the user wants to book, ask for their name first, then preferred date/time
            - Once you have all information, confirm it back to the user
            - Use natural language, not robotic responses
            
            Respond naturally to the user's messages.
          PROMPT
        }
      ]
    end

    puts "✓ Chat Workflow created/updated"
    puts "  - Name: #{workflow.name}"
    puts "  - Enabled: #{workflow.enabled}"
    puts "  - Steps: #{workflow.steps.count}"
    puts

    puts "=" * 80
    puts "✅ CHAT WORKFLOW SETUP COMPLETE!"
    puts "=" * 80
    puts
    puts "You can now test the chat widget - it will use this workflow for natural conversation."
    puts "Make sure your OpenAI API key is configured in Rails credentials."
  end

  desc "Setup Chat Workflow with automatic booking extraction and saving"
  task setup_chat_with_booking: :environment do
    puts "=" * 80
    puts "SETTING UP CHAT WORKFLOW WITH BOOKING EXTRACTION"
    puts "=" * 80
    puts

    # Find or create test brand
    brand = Brand.find_or_create_by!(subdomain: "testbrand") do |b|
      b.name = "Test Brand"
    end

    puts "✓ Brand: #{brand.name} (subdomain: #{brand.subdomain})"
    puts

    # Create Chat Workflow with booking extraction
    workflow = Workflow.find_or_create_by!(brand: brand, name: "Chat Workflow with Booking") do |w|
      w.enabled = true
      w.steps = [
        {
          "type" => "chat",
          "system_prompt" => <<~PROMPT
            You are a helpful and friendly assistant for booking appointments and consultations.
            
            Your role:
            - Be conversational and natural
            - Ask clarifying questions when needed
            - Remember information from the conversation
            - Help users book appointments by collecting: name, preferred date/time, and reason for visit
            - Be concise but friendly
            - Confirm details before finalizing bookings
            
            Guidelines:
            - Keep responses short (1-2 sentences)
            - Be warm and professional
            - If the user wants to book, ask for their name first, then preferred date/time
            - Once you have all information, confirm it back to the user
            - Use natural language, not robotic responses
            
            Respond naturally to the user's messages.
          PROMPT
        },
        {
          "type" => "ai",
          "instruction" => "Extract booking information from the conversation. Look for: customer name, preferred date, preferred time, and reason/service type. Return JSON with fields: name, date, time, service_type. If any information is missing, return null for that field.",
          "variable" => "booking_info"
        },
        {
          "type" => "save",
          "model" => "lead",
          "fields" => {
            "form_type" => "booking_request",
            "status" => "new"
          }
        }
      ]
    end

    puts "✓ Chat Workflow with Booking created/updated"
    puts "  - Name: #{workflow.name}"
    puts "  - Enabled: #{workflow.enabled}"
    puts "  - Steps: #{workflow.steps.count}"
    puts "    Step 1: Chat (conversational AI)"
    puts "    Step 2: AI (extract booking info)"
    puts "    Step 3: Save (create lead)"
    puts

    puts "=" * 80
    puts "✅ CHAT WORKFLOW WITH BOOKING SETUP COMPLETE!"
    puts "=" * 80
    puts
    puts "This workflow will:"
    puts "  1. Have natural conversation with the user"
    puts "  2. Extract booking information from the conversation"
    puts "  3. Save it as a Lead (requires customer to be set)"
    puts
    puts "Note: To save actual Bookings, you need to create a customer first."
    puts "      The current workflow saves Leads which can be converted to Bookings later."
  end
end
