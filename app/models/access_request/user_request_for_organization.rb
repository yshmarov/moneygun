# frozen_string_literal: true

class AccessRequest::UserRequestForOrganization < AccessRequest
  after_create :notify_admins

  private

  def after_approve
    Membership::RequestAcceptedNotifier.with(organization:).deliver(user)
  end

  def after_reject
    Membership::RequestRejectedNotifier.with(organization:).deliver(user)
  end

  def notify_admins
    admin_users = organization.memberships.where(role: :admin).includes(:user).map(&:user)
    return if admin_users.empty?

    Membership::JoinRequestReceivedNotifier.with(
      organization: organization,
      user_name: user.email
    ).deliver(admin_users)
  end
end
