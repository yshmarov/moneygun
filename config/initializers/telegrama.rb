# Telegrama.configure do |config|
#   config.bot_token = Rails.application.credentials.dig(Rails.env.to_sym, :telegram, :bot_token)
#   config.chat_id   = Rails.application.credentials.dig(Rails.env.to_sym, :telegram, :chat_id)
#   config.default_parse_mode = "MarkdownV2"

#   # Optional prefix/suffix for all messages (useful to identify messages from different apps or environments)
#   config.message_prefix = nil  # Will be prepended to all messages if set
#   config.message_suffix = nil  # Will be appended to all messages if set

#   # Default formatting options
#   config.formatting_options = {
#     escape_markdown: true,    # Escape markdown special characters
#     obfuscate_emails: false,  # Off by default, enable if needed (it anonymizes email addresses in the message to things like abc...d@gmail.com)
#     escape_html: false,       # Optionally escape HTML characters
#     truncate: 4096            # Truncate if message exceeds Telegram's limit (or a custom limit)
#   }

#   # HTTP client options
#   config.client_options = {
#     timeout: 30,               # HTTP request timeout in seconds (default: 30s)
#     retry_count: 3,            # Number of retries for failed requests (default: 3)
#     retry_delay: 1             # Delay between retries in seconds (default: 1s)
#   }

#   config.deliver_message_async = false           # Enable async message delivery with ActiveJob (enqueue the send_message call to offload message sending from the request cycle)
#   config.deliver_message_queue = "default"       # Use a custom ActiveJob queue
# end
