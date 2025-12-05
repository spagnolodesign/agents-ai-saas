namespace :db do
  desc "Clean all data except brands, keep only test brand"
  task clean: :environment do
    puts "=" * 80
    puts "CLEANING DATABASE - KEEPING ONLY TEST BRAND"
    puts "=" * 80
    puts

    # Skip confirmation if FORCE=true is set
    unless ENV["FORCE"] == "true"
      puts "⚠️  This will DELETE ALL data except brands."
      puts "   Set FORCE=true to skip this warning: rake db:clean FORCE=true"
      puts
      exit
    end

    puts "🗑️  Deleting data..."

    # Set tenant context to nil to avoid tenant scoping issues
    ActsAsTenant.current_tenant = nil

    # Delete in order to respect foreign key constraints
    deleted_counts = {}

    # Delete messages first (they reference conversations)
    deleted_counts[:messages] = Message.count
    Message.delete_all
    puts "  ✓ Deleted #{deleted_counts[:messages]} messages"

    # Delete conversations (they reference customers and brands)
    deleted_counts[:conversations] = Conversation.count
    Conversation.delete_all
    puts "  ✓ Deleted #{deleted_counts[:conversations]} conversations"

    # Delete answered_fields (they reference leads)
    deleted_counts[:answered_fields] = AnsweredField.count
    AnsweredField.delete_all
    puts "  ✓ Deleted #{deleted_counts[:answered_fields]} answered_fields"

    # Delete leads (they reference customers and brands)
    deleted_counts[:leads] = Lead.count
    Lead.delete_all
    puts "  ✓ Deleted #{deleted_counts[:leads]} leads"

    # Delete bookings (they reference customers and brands)
    deleted_counts[:bookings] = Booking.count
    Booking.delete_all
    puts "  ✓ Deleted #{deleted_counts[:bookings]} bookings"

    # Delete payments (they reference bookings and brands)
    deleted_counts[:payments] = Payment.count
    Payment.delete_all
    puts "  ✓ Deleted #{deleted_counts[:payments]} payments"

    # Delete invoices (they reference payments, bookings, and brands)
    deleted_counts[:invoices] = Invoice.count
    Invoice.delete_all
    puts "  ✓ Deleted #{deleted_counts[:invoices]} invoices"

    # Delete events (they reference brands)
    deleted_counts[:events] = Event.count
    Event.delete_all
    puts "  ✓ Deleted #{deleted_counts[:events]} events"

    # Delete workflows (they reference brands)
    deleted_counts[:workflows] = Workflow.count
    Workflow.delete_all
    puts "  ✓ Deleted #{deleted_counts[:workflows]} workflows"

    # Delete brand_templates (they reference templates and brands)
    deleted_counts[:brand_templates] = BrandTemplate.count
    BrandTemplate.delete_all
    puts "  ✓ Deleted #{deleted_counts[:brand_templates]} brand_templates"

    # Delete templates
    deleted_counts[:templates] = Template.count
    Template.delete_all
    puts "  ✓ Deleted #{deleted_counts[:templates]} templates"

    # Delete customers (they reference brands)
    deleted_counts[:customers] = Customer.count
    Customer.delete_all
    puts "  ✓ Deleted #{deleted_counts[:customers]} customers"

    # Delete users (they reference brands)
    deleted_counts[:users] = User.count
    User.delete_all
    puts "  ✓ Deleted #{deleted_counts[:users]} users"

    # Keep only test brand, delete others
    test_brand = Brand.find_by(subdomain: "testbrand")
    if test_brand
      puts "  ✓ Keeping test brand: #{test_brand.name} (ID: #{test_brand.id})"
    else
      # Create test brand if it doesn't exist
      test_brand = Brand.create!(
        subdomain: "testbrand",
        name: "Test Brand"
      )
      puts "  ✓ Created test brand: #{test_brand.name} (ID: #{test_brand.id})"
    end

    other_brands = Brand.where.not(id: test_brand.id)
    deleted_counts[:brands] = other_brands.count
    other_brands.delete_all
    puts "  ✓ Deleted #{deleted_counts[:brands]} other brands"

    puts
    puts "=" * 80
    puts "✅ DATABASE CLEANED!"
    puts "=" * 80
    puts
    puts "Summary:"
    deleted_counts.each do |model, count|
      puts "  - #{model}: #{count} deleted"
    end
    puts
    puts "Remaining:"
    puts "  - Brands: #{Brand.count} (#{Brand.first&.name})"
    puts "  - All other tables: 0"
    puts
  end

  desc "Clean database and setup fresh test environment"
  task clean_and_setup: [:clean, "workflow:setup_chat"] do
    puts "=" * 80
    puts "✅ FRESH TEST ENVIRONMENT READY!"
    puts "=" * 80
    puts
    puts "You can now:"
    puts "  1. Test the chat widget at http://localhost:5173"
    puts "  2. View bookings/leads with: rake bookings:view"
    puts
  end
end

