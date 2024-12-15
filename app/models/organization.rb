class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :inboxes, dependent: :destroy

  validates :name, presence: true

  has_one_attached :logo

  def self.ransackable_attributes auth_object = nil
    %w[id name]
  end

  def self.ransackable_associations auth_object = nil
    %w[]
  end
end
