class AccessRequest::InviteToOrganization < AccessRequest
  validates :type, presence: true

  after_create :send_invitation_notification

  def approve!
    transaction do
      update!(status: :approved, completed_by: user)
      user.memberships.create(organization: organization)
    end
  rescue StandardError => e
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
