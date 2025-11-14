class Model < ApplicationRecord
  acts_as_model chats_foreign_key: :model_id
end
