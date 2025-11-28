# frozen_string_literal: true

class AccessRequest::InviteToOrganization < AccessRequest
  validates :type, presence: true

  after_create :send_invitation_notification

  def approve!
    transaction do
      update!(status: :approved, completed_by: user)
      user.memberships.find_or_create_by!(organization: organization)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!
    update!(status: :rejected, completed_by: user)
  end

  private

  def send_invitation_notification
    Membership::InvitationNotifier.with(organization: organization).deliver(user)
  end
end
