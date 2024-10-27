class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  has_many :inboxes, dependent: :destroy

  validates :name, presence: true

  has_one_attached :logo
end
