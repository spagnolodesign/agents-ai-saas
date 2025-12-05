module Workflows
  module Steps
    class SaveStep < BaseStep
      def call
        model_name = step["model"]
        fields = step["fields"] || {}

        model_class = resolve_model(model_name)
        return if model_class.nil?

        resolved_fields = resolve_fields(fields)

        record = create_record(model_class, resolved_fields)

        context.set(:last_saved_record_id, record.id) if record&.id

        nil
      end

      private

      def resolve_model(model_name)
        case model_name.to_s.downcase
        when "booking"
          Booking
        when "lead"
          Lead
        else
          context.errors << "Unknown model: #{model_name}"
          nil
        end
      end

      def resolve_fields(fields)
        resolved = {}

        fields.each do |key, value|
          resolved[key] = substitute_value(value)
        end

        resolved
      end

      def substitute_value(value)
        return value unless value.is_a?(String)

        resolve_placeholders(value)
      end

      def resolve_placeholders(value)
        value.gsub(/\{\{context\.(.*?)\}\}/) do
          path = Regexp.last_match(1).split(".")
          data = context.get(path.shift)

          path.each do |key|
            data = data.is_a?(Hash) ? data[key] : nil
            break if data.nil?
          end

          data.to_s
        end
      end

      def create_record(model_class, fields)
        # Ensure we're operating under the current tenant
        brand = context.customer&.brand || ActsAsTenant.current_tenant

        return nil unless brand

        ActsAsTenant.with_tenant(brand) do
          # For Booking, we need customer
          if model_class == Booking
            customer = context.customer
            return nil unless customer

            model_class.create!(
              brand: brand,
              customer: customer,
              service_type: fields["service_type"] || "consultation",
              date: parse_date(fields["date"]),
              status: fields["status"] || "pending",
              notes: fields["notes"],
              metadata: fields["metadata"] || {}
            )
          # For Lead, we need customer
          elsif model_class == Lead
            customer = context.customer
            return nil unless customer

            lead_attrs = {
              brand: brand,
              customer: customer,
              form_type: fields["form_type"] || "contact",
              status: fields["status"] || "new"
            }

            model_class.create!(lead_attrs)
          end
        end
      end

      def parse_date(date_value)
        return nil if date_value.nil? || date_value.empty?

        case date_value
        when Date
          date_value
        when String
          Date.parse(date_value)
        else
          date_value
        end
      rescue ArgumentError
        nil
      end
    end
  end
end
