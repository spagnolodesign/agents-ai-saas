namespace :bookings do
  desc "View all conversations, bookings, and leads for a brand"
  task view: :environment do
    puts "=" * 80
    puts "VIEWING CONVERSATIONS, BOOKINGS, AND LEADS"
    puts "=" * 80
    puts

    # Find brand
    brand = Brand.find_by(subdomain: "testbrand") || Brand.first
    unless brand
      puts "❌ No brand found. Please create a brand first."
      exit
    end

    puts "📦 Brand: #{brand.name} (subdomain: #{brand.subdomain})"
    puts

    # Set tenant context
    ActsAsTenant.current_tenant = brand

    # Show conversations
    puts "=" * 80
    puts "CONVERSATIONS"
    puts "=" * 80
    conversations = brand.conversations.order(created_at: :desc).limit(10)

    if conversations.any?
      conversations.each do |conv|
        puts
        puts "Conversation ID: #{conv.id}"
        puts "  Customer: #{conv.customer ? conv.customer.name : 'Anonymous'}"
        puts "  Status: #{conv.status}"
        puts "  Messages: #{conv.messages.count}"
        puts "  Created: #{conv.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
        puts "  Workflow Context:"
        if conv.workflow_context.present?
          context = conv.workflow_context
          puts "    - Step Index: #{context['current_step_index'] || 0}"
          if context['state'].present?
            puts "    - Context Keys: #{context['state'].keys.join(', ')}"
            # Show important context values
            context['state'].each do |key, value|
              next if key == "conversation_id" # Skip this
              if value.is_a?(Hash)
                puts "    - #{key}: #{value.keys.join(', ')}"
              elsif value.is_a?(String) && value.length < 100
                puts "    - #{key}: #{value}"
              end
            end
          end
        else
          puts "    (empty)"
        end

        # Show last few messages
        last_messages = conv.messages.order(created_at: :desc).limit(3).reverse
        if last_messages.any?
          puts "  Last Messages:"
          last_messages.each do |msg|
            icon = msg.role == "user" ? "👤" : "🤖"
            puts "    #{icon} [#{msg.role}]: #{msg.content[0..80]}#{msg.content.length > 80 ? '...' : ''}"
          end
        end
      end
    else
      puts "No conversations found."
    end

    puts
    puts "=" * 80
    puts "BOOKINGS"
    puts "=" * 80

    bookings = brand.bookings.order(created_at: :desc).limit(20)

    if bookings.any?
      bookings.each do |booking|
        puts
        puts "Booking ID: #{booking.id}"
        puts "  Customer: #{booking.customer.name} (#{booking.customer.email})"
        puts "  Service: #{booking.service_type}"
        puts "  Date: #{booking.date}"
        puts "  Time: #{booking.time ? booking.time.strftime('%H:%M') : 'Not set'}"
        puts "  Status: #{booking.status}"
        puts "  Notes: #{booking.notes}" if booking.notes.present?
        puts "  Created: #{booking.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
        if booking.metadata.present?
          puts "  Metadata: #{booking.metadata.inspect}"
        end
      end
      puts
      puts "Total bookings: #{bookings.count}"
    else
      puts "No bookings found."
    end

    puts
    puts "=" * 80
    puts "LEADS"
    puts "=" * 80

    leads = brand.leads.order(created_at: :desc).limit(20)

    if leads.any?
      leads.each do |lead|
        puts
        puts "Lead ID: #{lead.id}"
        puts "  Customer: #{lead.customer.name} (#{lead.customer.email})"
        puts "  Form Type: #{lead.form_type}"
        puts "  Status: #{lead.status}"
        puts "  Created: #{lead.created_at.strftime('%Y-%m-%d %H:%M:%S')}"
        if lead.answered_fields.any?
          puts "  Answered Fields:"
          lead.answered_fields.each do |field|
            puts "    - #{field.field_name}: #{field.field_value}"
          end
        end
      end
      puts
      puts "Total leads: #{leads.count}"
    else
      puts "No leads found."
    end

    puts
    puts "=" * 80
    puts "✅ DONE"
    puts "=" * 80
  end
end

