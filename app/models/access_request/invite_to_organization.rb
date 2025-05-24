class AccessRequest::InviteToOrganization < AccessRequest
  validates :type, presence: true

  def approve!
    transaction do
      update!(status: :approved, completed_by: user)
      user.memberships.create(organization: organization)
    end
  rescue => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!
    update!(status: :rejected, completed_by: user)
  end
end
