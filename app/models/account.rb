class Account < ApplicationRecord
  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users

  validates :name, presence: true

  has_one_attached :logo
end
