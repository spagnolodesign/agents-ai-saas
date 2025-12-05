<template>
  <div class="chat-widget">
    <div class="chat-header">
      <h2>Chat Assistant</h2>
      <div class="subdomain-info">
        <small>Tenant: {{ subdomain }}</small>
      </div>
    </div>

    <div class="chat-messages" ref="messagesContainer">
      <div
        v-for="(message, index) in messages"
        :key="index"
        :class="['message', message.role]"
      >
        <div class="message-content">
          {{ message.content }}
        </div>
        <div class="message-time">
          {{ formatTime(message.timestamp) }}
        </div>
      </div>

      <div v-if="loading" class="message assistant">
        <div class="message-content">
          <span class="typing-indicator">...</span>
        </div>
      </div>
    </div>

    <div class="chat-input-container">
      <form @submit.prevent="sendMessage" class="chat-form">
        <input
          v-model="inputMessage"
          type="text"
          placeholder="Type your message..."
          class="chat-input"
          :disabled="loading"
        />
        <button
          type="submit"
          class="send-button"
          :disabled="loading || !inputMessage.trim()"
        >
          Send
        </button>
      </form>
    </div>

    <div v-if="error" class="error-message">
      {{ error }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ChatWidget',
  data() {
    return {
      messages: [],
      inputMessage: '',
      loading: false,
      error: null,
      conversationId: null,
      apiUrl: 'http://localhost:3000/api/v1/chat',
      subdomain: 'testbrand' // Default subdomain for testing
    }
  },
  mounted() {
    // Add welcome message
    this.addMessage('assistant', 'Hello! How can I help you today?')
  },
  methods: {
    async sendMessage() {
      const message = this.inputMessage.trim()
      if (!message || this.loading) return

      // Add user message to UI
      this.addMessage('user', message)
      this.inputMessage = ''
      this.error = null
      this.loading = true

      try {
        const response = await fetch(this.apiUrl, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-Subdomain': this.subdomain
          },
          body: JSON.stringify({
            message: message,
            conversation_id: this.conversationId
          })
        })

        const data = await response.json()

        if (!response.ok) {
          throw new Error(data.error || 'Failed to send message')
        }

        // Store conversation ID for subsequent messages
        if (data.conversation_id) {
          this.conversationId = data.conversation_id
        }

        // Add assistant reply if present
        if (data.reply) {
          this.addMessage('assistant', data.reply)
        }

        // If halted, workflow is waiting for user input
        if (data.halted) {
          console.log('Workflow halted, waiting for user input')
        }
      } catch (err) {
        this.error = err.message || 'An error occurred'
        console.error('Chat error:', err)
      } finally {
        this.loading = false
        this.$nextTick(() => {
          this.scrollToBottom()
        })
      }
    },
    addMessage(role, content) {
      this.messages.push({
        role,
        content,
        timestamp: new Date()
      })
      this.$nextTick(() => {
        this.scrollToBottom()
      })
    },
    scrollToBottom() {
      const container = this.$refs.messagesContainer
      if (container) {
        container.scrollTop = container.scrollHeight
      }
    },
    formatTime(date) {
      return new Date(date).toLocaleTimeString('en-US', {
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
.chat-widget {
  display: flex;
  flex-direction: column;
  height: 100%;
  background: white;
  border-radius: 12px;
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  overflow: hidden;
}

.chat-header {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  text-align: center;
}

.chat-header h2 {
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 4px;
}

.subdomain-info {
  font-size: 11px;
  opacity: 0.9;
  margin-top: 4px;
}

.chat-messages {
  flex: 1;
  overflow-y: auto;
  padding: 20px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.message {
  display: flex;
  flex-direction: column;
  max-width: 75%;
  animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.message.user {
  align-self: flex-end;
  align-items: flex-end;
}

.message.assistant {
  align-self: flex-start;
  align-items: flex-start;
}

.message-content {
  padding: 12px 16px;
  border-radius: 18px;
  word-wrap: break-word;
  line-height: 1.4;
}

.message.user .message-content {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border-bottom-right-radius: 4px;
}

.message.assistant .message-content {
  background: #f1f3f5;
  color: #212529;
  border-bottom-left-radius: 4px;
}

.message-time {
  font-size: 11px;
  color: #6c757d;
  margin-top: 4px;
  padding: 0 4px;
}

.typing-indicator {
  display: inline-block;
  animation: typing 1.4s infinite;
}

@keyframes typing {
  0%, 60%, 100% {
    opacity: 0.3;
  }
  30% {
    opacity: 1;
  }
}

.chat-input-container {
  padding: 16px;
  border-top: 1px solid #e9ecef;
  background: white;
}

.chat-form {
  display: flex;
  gap: 8px;
}

.chat-input {
  flex: 1;
  padding: 12px 16px;
  border: 2px solid #e9ecef;
  border-radius: 24px;
  font-size: 14px;
  outline: none;
  transition: border-color 0.2s;
}

.chat-input:focus {
  border-color: #667eea;
}

.chat-input:disabled {
  background: #f8f9fa;
  cursor: not-allowed;
}

.send-button {
  padding: 12px 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 24px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: transform 0.2s, opacity 0.2s;
}

.send-button:hover:not(:disabled) {
  transform: translateY(-1px);
}

.send-button:active:not(:disabled) {
  transform: translateY(0);
}

.send-button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.error-message {
  padding: 12px 16px;
  background: #fee;
  color: #c33;
  font-size: 13px;
  text-align: center;
  border-top: 1px solid #fcc;
}

/* Scrollbar styling */
.chat-messages::-webkit-scrollbar {
  width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
  background: #f1f1f1;
}

.chat-messages::-webkit-scrollbar-thumb {
  background: #888;
  border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
  background: #555;
}
</style>

