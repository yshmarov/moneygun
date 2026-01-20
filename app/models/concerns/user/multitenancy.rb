# frozen_string_literal: true

module User::Multitenancy
  extend ActiveSupport::Concern

  included do
    has_many :memberships, dependent: :nullify # Changed from :destroy - archive instead of delete
    has_many :organizations, -> { joins(:memberships).where(memberships: { suspended_at: nil }) }, through: :memberships

    # No dependent option - we handle deletion manually in before_destroy
    has_many :owned_organizations, class_name: "Organization", foreign_key: :owner_id,
                                   inverse_of: :owner, dependent: nil

    has_many :received_invitations, class_name: "AccessRequest::InviteToOrganization", dependent: :destroy
    has_many :sent_join_requests, class_name: "AccessRequest::UserRequestForOrganization", dependent: :destroy

    after_create_commit :create_default_organization
    before_destroy :validate_and_cleanup_before_destroy
    after_destroy :archive_orphaned_memberships
  end

  def organizations_with_pending_invitations
    Organization.where(id: received_invitations.pending.select(:organization_id))
  end

  def organizations_with_pending_join_requests
    Organization.where(id: sent_join_requests.pending.select(:organization_id))
  end

  private

  def create_default_organization
    return if invitation_created_at.present?

    organization_name = email.split("@").first
    organization = Organization.create!(name: organization_name, owner: self)
    organization.memberships.first.update(role: Membership.roles[:admin])
  end

  def validate_and_cleanup_before_destroy
    owned_organizations.each do |org|
      if org.memberships.where.not(user_id: id).exists?
        errors.add(:base, I18n.t("errors.models.user.cannot_delete_owns_org_with_members", org_name: org.name))
        throw(:abort)
      end
      if org.has_access?
        errors.add(:base, I18n.t("errors.models.user.cannot_delete_active_subscription", org_name: org.name))
        throw(:abort)
      end
    end

    # If we pass validation, destroy owned organizations (solo orgs without subscriptions)
    owned_organizations.each(&:destroy!)
  end

  def archive_orphaned_memberships
    # Memberships already nullified by dependent: :nullify
    # Set suspended_at for any memberships that now have nil user_id
    Membership.where(user_id: nil, suspended_at: nil).update_all(suspended_at: Time.current)
  end
end
