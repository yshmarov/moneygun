# frozen_string_literal: true

module Organization::Transfer
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: "User"
  end

  def transfer_ownership(user_id)
    previous_owner = owner
    membership = memberships.active.find_by(user_id: user_id)
    return false unless membership

    new_owner = membership.user

    ApplicationRecord.transaction do
      membership.update!(role: Membership.roles[:admin])
      update!(owner: new_owner)
      AuditLog.log!(
        organization: self,
        actor: Current.membership,
        action: "organization.ownership_transferred",
        actor_kind: Current.audit_actor_kind,
        metadata: { changes: { owner_user_id: [previous_owner.id, new_owner.id], owner_email: [previous_owner.email, new_owner.email] } }
      )
    end

    OrganizationMailer.ownership_transferred(new_owner, self).deliver_later
  rescue StandardError => e
    Rails.logger.error("Ownership transfer failed: #{e.message}")
    false
  end

  def owner?(user)
    owner_id == user.id
  end

  def can_transfer?(user)
    owner?(user) && memberships.active.where.not(user: user).exists?
  end
end
