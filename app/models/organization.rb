class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :inboxes, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 20 }

  has_one_attached :logo

  pay_customer default_payment_processor: :stripe, stripe_attributes: :stripe_attributes

  def email
    owner.email
  end

  def stripe_attributes(pay_customer)
    {
      metadata: {
        pay_customer_id: pay_customer.id,
        user_id: id
      }
    }
  end

  def pay_should_sync_customer?
    super || self.saved_change_to_owner_id?
  end
end
