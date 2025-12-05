module Api
  module V1
    class ChatController < ApplicationController
      # POST /api/v1/chat
      #
      # Params:
      #   - conversation_id (optional)
      #   - message (required)
      #
      # If conversation_id is missing, create a new conversation for the current tenant.
      #
      def create
        message = params[:message].to_s.strip
        return render json: { error: "Message cannot be empty" }, status: 422 if message.blank?

        # Resolve current brand (tenant)
        brand = current_brand
        return render json: { error: "Brand not resolved" }, status: 422 unless brand

        # Load or create conversation
        conversation = find_or_create_conversation(brand)

        # Run ConversationEngine
        engine = ConversationEngine.new
        reply = engine.process(conversation: conversation, user_message: message)

        render json: {
          conversation_id: conversation.id,
          reply: reply,
          halted: reply.nil?
        }
      rescue => e
        Rails.logger.error("ChatController ERROR: #{e.message}")
        render json: { error: "Internal server error" }, status: 500
      end

      private

      def find_or_create_conversation(brand)
        # If conversation_id exists, use it
        if params[:conversation_id].present?
          return brand.conversations.find(params[:conversation_id])
        end

        # Otherwise create a new anonymous conversation
        brand.conversations.create!(
          customer: nil,
          status: "active",
          workflow_context: {}
        )
      end
    end
  end
end

