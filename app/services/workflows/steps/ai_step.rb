module Workflows
    module Steps
      class AiStep < BaseStep
        def call
          variable = step["variable"]
          instruction = step["instruction"]

          # Always resolve template with fallback
          template = resolve_template
          brand_template = resolve_brand_template(template)

          # Build system prompt (static builder, not instance)
          system_prompt = Ai::PromptBuilder.build(
            template: template,
            brand_template: brand_template,
            context: context
          )

          # Call the AI Gateway
          raw_output = Ai::AiGateway.call(
            instruction: instruction,
            system_prompt: system_prompt,
            context: context.state
          )

          return nil if raw_output.nil?

          # Always attempt JSON extraction (even if not explicitly requested)
          structured = Ai::JsonExtractor.extract(raw_output)

          # Save both raw and structured output
          # This is vital for frontend and debugging.
          context.set("#{variable}_raw", raw_output)

          if structured.is_a?(Hash) && structured.any?
            context.set(variable, structured)
          else
            context.set(variable, raw_output)
          end

          nil
        end

        private

        # Always fallback to "default" template
        def resolve_template
          if step["template_id"]
            Template.find_by(id: step["template_id"])
          else
            Template.find_by(name: "default")
          end
        end

        def resolve_brand_template(template)
          return nil unless template
          return nil unless context.customer

          BrandTemplate.find_by(
            template: template,
            brand: context.customer.brand
          )
        end
      end
    end
end
