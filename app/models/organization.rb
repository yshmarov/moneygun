# frozen_string_literal: true

class Organization < ApplicationRecord
  ICON = "svg/briefcase.svg"
  AUDITED_FIELDS = %w[name privacy_setting website admin_granted_access].freeze

  has_many :projects, dependent: :destroy
  has_many :data_exports, dependent: :destroy

  include Organization::Multitenancy
  include Organization::Transfer
  include Organization::Billing
  include Organization::Logo
  include Organization::Community
  include Auditable

  validates :name, presence: true
  validates :website, format: { with: %r{\Ahttps?://.+\z}i }, allow_blank: true

  audit_changes(*AUDITED_FIELDS, action: "organization.updated", mini_app: "organization", organization: :itself)

  before_destroy :ensure_no_active_subscription, prepend: true

  def self.ransackable_attributes(_auth_object = nil)
    %w[id name]
  end

  def self.ransackable_associations(_auth_object = nil)
    []
  end

  def active_storage_publicly_accessible?
    true
  end

  def undeletable_reasons
    active_subscription? ? [:has_active_subscription] : []
  end

  def erase!
    recipients = memberships.active.includes(:user).map(&:user) - [Current.user]
    return false unless destroy

    Membership::OrganizationDeletedNotifier.with(organization_name: name).deliver(recipients) if recipients.any?
    true
  end

  private

  def ensure_no_active_subscription
    return unless active_subscription?

    errors.add(:base, :has_active_subscription)
    throw(:abort)
  end
end
