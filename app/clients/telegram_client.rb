# client = TelegramClient.new
# client.create_invite_link(1234567890)
# client.send_message(1234567890, "Hello, world!", parse_mode: "HTML")
# client.send_message(1234567890, "Hello, world!", parse_mode: "HTML", disable_web_page_preview: true)
# client.send_message(1234567890, "Hello, world!", parse_mode: "HTML", disable_web_page_preview: true, reply_to_message_id: 1234567890)
# client.send_message(1234567890, "Hello, world!", parse_mode: "HTML", disable_web_page_preview: true, reply_to_message_id: 1234567890, reply_markup: {
#   inline_keyboard: [[{ text: "Button", url: "https://www.google.com" }]]
# })

class TelegramClient < BaseClient
  BASE_URL = "https://api.telegram.org"

  def initialize
    @bot_token = Rails.application.credentials.dig(:telegram, :bot_secret)
    @default_chat_id = Rails.application.credentials.dig(:telegram, :members_only_chat_id)
    # @example_user_id = "450462613"

    raise ConfigurationError, "Telegram bot token not found in credentials" unless @bot_token

    super(base_url: BASE_URL)
  end

  # Bot API methods
  def kick_user(user_id, chat_id: nil)
    chat_id ||= @default_chat_id

    post("/bot#{@bot_token}/kickChatMember", {
      chat_id: chat_id,
      user_id: user_id
    })
  end

  def unban_user(user_id, chat_id: nil)
    chat_id ||= @default_chat_id

    post("/bot#{@bot_token}/unbanChatMember", {
      chat_id: chat_id,
      user_id: user_id,
      only_if_banned: true
    })
  end

  # https://core.telegram.org/tdlib/docs/classtd_1_1td__api_1_1create_chat_invite_link.html
  def create_invite_link(chat_id: nil, expires_at: nil, member_limit: 1)
    chat_id ||= @default_chat_id

    payload = { chat_id: chat_id }
    payload[:expire_date] = expires_at.to_i if expires_at
    payload[:member_limit] = member_limit if member_limit

    response = post("/bot#{@bot_token}/createChatInviteLink", payload)
    response.dig("result", "invite_link")
  end

  def send_message(chat_id, text, **options)
    payload = {
      chat_id: chat_id,
      text: text
    }.merge(options)

    post("/bot#{@bot_token}/sendMessage", payload)
  end

  def send_invite_link_to_user(user_id, invite_link = nil, chat_id: nil)
    invite_link ||= create_invite_link(chat_id: chat_id)

    send_message(user_id, "Join the group using this link: #{invite_link}")
  end

  def get_chat_info(chat_id: nil)
    chat_id ||= @default_chat_id

    get("/bot#{@bot_token}/getChat", { chat_id: chat_id })
  end

  def get_chat_member(user_id, chat_id: nil)
    chat_id ||= @default_chat_id

    get("/bot#{@bot_token}/getChatMember", {
      chat_id: chat_id,
      user_id: user_id
    })
  end

  private

  class ConfigurationError < StandardError; end
end
