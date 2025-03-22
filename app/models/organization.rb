class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :inboxes, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 20 }

  has_one_attached :logo
end
