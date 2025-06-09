class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  has_many :user_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
  has_many :user_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

  enum :privacy_setting, { private: "private", restricted: "restricted", public: "public" }, default: :private, prefix: true

  include Transfer

  has_many :projects, dependent: :destroy

  MIN_NAME_LENGTH = 3
  MAX_NAME_LENGTH = 20

  validates :name, presence: true
  validates :name, length: { minimum: MIN_NAME_LENGTH, maximum: MAX_NAME_LENGTH }

  validates :logo, content_type: IMAGE_CONTENT_TYPES
  has_one_attached :logo do |attachable|
    attachable.variant :thumb, resize_to_limit: [ 100, 100 ]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  pay_customer default_payment_processor: :stripe, stripe_attributes: :stripe_attributes

  delegate :email, to: :owner

  def stripe_attributes(pay_customer)
    {
      metadata: {
        pay_customer_id: pay_customer.id,
        organization_id: id
      }
    }
  end

  def pay_should_sync_customer?
    super || saved_change_to_owner_id?
  end

  def participant?(user)
    users.include?(user)
  end
end
