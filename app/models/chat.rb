class Chat < ApplicationRecord
  acts_as_chat messages_foreign_key: :chat_id
end
