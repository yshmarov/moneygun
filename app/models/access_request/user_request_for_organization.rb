class AccessRequest::UserRequestForOrganization < AccessRequest
  validates :type, presence: true

  def approve!(completed_by:)
    transaction do
      update!(status: :approved, completed_by:)
      organization.memberships.create(user:)
      MembershipRequestAcceptedNotifier.with(organization: organization).deliver(user)
    end
  rescue => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!(completed_by:)
    update!(status: :rejected, completed_by:)
  end
end
