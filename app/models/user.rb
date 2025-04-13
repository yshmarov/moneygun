class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_many :memberships, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id, inverse_of: :owner, dependent: :destroy

  def self.ransackable_attributes(auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
