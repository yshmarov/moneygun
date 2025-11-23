# frozen_string_literal: true

class AccessRequest::UserRequestForOrganization < AccessRequest
  validates :type, presence: true

  def approve!(completed_by:)
    transaction do
      update!(status: :approved, completed_by:)
      organization.memberships.find_or_create_by!(user: user)
      Membership::RequestAcceptedNotifier.with(organization: organization).deliver(user)
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotUnique => e
    raise ActiveRecord::Rollback, e.message
  end

  def reject!(completed_by:)
    update!(status: :rejected, completed_by:)
    Membership::RequestRejectedNotifier.with(organization: organization).deliver(user)
  end
end
