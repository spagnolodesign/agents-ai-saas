# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_12_05_120001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answered_fields", force: :cascade do |t|
    t.bigint "lead_id", null: false
    t.string "field_name"
    t.string "field_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id"], name: "index_answered_fields_on_lead_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "customer_id", null: false
    t.string "service_type"
    t.date "date"
    t.datetime "time"
    t.string "status"
    t.text "notes"
    t.jsonb "metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "customer_id"], name: "index_bookings_on_brand_id_and_customer_id"
    t.index ["brand_id", "date"], name: "index_bookings_on_brand_id_and_date"
    t.index ["brand_id", "status"], name: "index_bookings_on_brand_id_and_status"
    t.index ["brand_id"], name: "index_bookings_on_brand_id"
    t.index ["customer_id"], name: "index_bookings_on_customer_id"
  end

  create_table "brand_templates", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "template_id", null: false
    t.text "custom_prompt"
    t.jsonb "overrides"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "template_id"], name: "index_brand_templates_on_brand_id_and_template_id", unique: true
    t.index ["brand_id"], name: "index_brand_templates_on_brand_id"
    t.index ["template_id"], name: "index_brand_templates_on_template_id"
  end

  create_table "brands", force: :cascade do |t|
    t.string "name"
    t.string "subdomain"
    t.jsonb "settings"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_brands_on_subdomain", unique: true
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "customer_id"
    t.string "status", default: "active"
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "workflow_context", default: {}
    t.index ["brand_id", "customer_id"], name: "index_conversations_on_brand_id_and_customer_id"
    t.index ["brand_id", "status"], name: "index_conversations_on_brand_id_and_status"
    t.index ["brand_id"], name: "index_conversations_on_brand_id"
    t.index ["customer_id"], name: "index_conversations_on_customer_id"
    t.index ["last_message_at"], name: "index_conversations_on_last_message_at"
  end

  create_table "customers", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "codice_fiscale"
    t.index ["brand_id", "codice_fiscale"], name: "index_customers_on_brand_id_and_codice_fiscale"
    t.index ["brand_id", "email"], name: "index_customers_on_brand_id_and_email"
    t.index ["brand_id"], name: "index_customers_on_brand_id"
  end

  create_table "events", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "event_type"
    t.datetime "occurred_at"
    t.jsonb "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "event_type"], name: "index_events_on_brand_id_and_event_type"
    t.index ["brand_id", "occurred_at"], name: "index_events_on_brand_id_and_occurred_at"
    t.index ["brand_id"], name: "index_events_on_brand_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "booking_id", null: false
    t.bigint "payment_id", null: false
    t.string "number"
    t.string "pdf_url"
    t.string "status"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_invoices_on_booking_id"
    t.index ["brand_id", "number"], name: "index_invoices_on_brand_id_and_number", unique: true
    t.index ["brand_id", "status"], name: "index_invoices_on_brand_id_and_status"
    t.index ["brand_id"], name: "index_invoices_on_brand_id"
    t.index ["payment_id"], name: "index_invoices_on_payment_id"
  end

  create_table "leads", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "customer_id", null: false
    t.string "form_type"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "customer_id"], name: "index_leads_on_brand_id_and_customer_id"
    t.index ["brand_id", "status"], name: "index_leads_on_brand_id_and_status"
    t.index ["brand_id"], name: "index_leads_on_brand_id"
    t.index ["customer_id"], name: "index_leads_on_customer_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.string "role", null: false
    t.text "content", null: false
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["role"], name: "index_messages_on_role"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.bigint "booking_id", null: false
    t.string "stripe_payment_intent_id"
    t.string "stripe_checkout_session_id"
    t.decimal "amount", precision: 10, scale: 2
    t.string "currency", default: "eur"
    t.string "status"
    t.string "payment_url"
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["booking_id"], name: "index_payments_on_booking_id"
    t.index ["brand_id", "booking_id"], name: "index_payments_on_brand_id_and_booking_id"
    t.index ["brand_id", "status"], name: "index_payments_on_brand_id_and_status"
    t.index ["brand_id", "stripe_payment_intent_id"], name: "index_payments_on_brand_id_and_stripe_payment_intent_id"
    t.index ["brand_id"], name: "index_payments_on_brand_id"
  end

  create_table "templates", force: :cascade do |t|
    t.string "name"
    t.text "base_prompt"
    t.jsonb "workflow_definition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "email"], name: "index_users_on_brand_id_and_email", unique: true
    t.index ["brand_id"], name: "index_users_on_brand_id"
  end

  create_table "workflows", force: :cascade do |t|
    t.bigint "brand_id", null: false
    t.string "name"
    t.jsonb "steps"
    t.boolean "enabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["brand_id", "enabled"], name: "index_workflows_on_brand_id_and_enabled"
    t.index ["brand_id"], name: "index_workflows_on_brand_id"
  end

  add_foreign_key "answered_fields", "leads"
  add_foreign_key "bookings", "brands"
  add_foreign_key "bookings", "customers"
  add_foreign_key "brand_templates", "brands"
  add_foreign_key "brand_templates", "templates"
  add_foreign_key "conversations", "brands"
  add_foreign_key "conversations", "customers"
  add_foreign_key "customers", "brands"
  add_foreign_key "events", "brands"
  add_foreign_key "invoices", "bookings"
  add_foreign_key "invoices", "brands"
  add_foreign_key "invoices", "payments"
  add_foreign_key "leads", "brands"
  add_foreign_key "leads", "customers"
  add_foreign_key "messages", "conversations"
  add_foreign_key "payments", "bookings"
  add_foreign_key "payments", "brands"
  add_foreign_key "users", "brands"
  add_foreign_key "workflows", "brands"
end
