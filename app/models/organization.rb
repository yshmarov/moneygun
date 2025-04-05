class Organization < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships
  belongs_to :owner, class_name: "User"

  include Transfer

  has_many :projects, dependent: :destroy

  validates :name, presence: true
  validates :name, length: { maximum: 20 }

  has_one_attached :logo

  pay_customer default_payment_processor: :stripe, stripe_attributes: :stripe_attributes
  has_credits

  def email
    owner.email
  end

  def stripe_attributes(pay_customer)
    {
      metadata: {
        pay_customer_id: pay_customer.id,
        organization_id: id
      }
    }
  end

  def pay_should_sync_customer?
    super || self.saved_change_to_owner_id?
  end

  after_create :give_new_organization_credits

  def give_new_organization_credits
    give_credits(10, reason: "new_organization")
  end
end
