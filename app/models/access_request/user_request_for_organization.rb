# frozen_string_literal: true

class AccessRequest::UserRequestForOrganization < AccessRequest
  private

  def after_approve
    Membership::RequestAcceptedNotifier.with(organization:).deliver(user)
  end

  def after_reject
    Membership::RequestRejectedNotifier.with(organization:).deliver(user)
  end
end
