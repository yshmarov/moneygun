class Account < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
  has_many :inboxes, dependent: :destroy

  validates :name, presence: true

  has_one_attached :logo
end
