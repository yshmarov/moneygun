# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/membership_mailer
class MembershipMailerPreview < ActionMailer::Preview
  def invitation_email
    organization = Organization.first
    user = User.first

    Membership::InvitationNotifier.with(organization: organization).deliver(user)
    notification = user.notifications.last

    MembershipMailer.invitation_email(notification)
  end

  def request_accepted_email
    organization = Organization.first
    user = User.first

    Membership::RequestAcceptedNotifier.with(organization: organization).deliver(user)
    notification = user.notifications.last

    MembershipMailer.request_accepted_email(notification)
  end

  def request_rejected_email
    organization = Organization.first
    user = User.first

    Membership::RequestRejectedNotifier.with(organization: organization).deliver(user)
    notification = user.notifications.last

    MembershipMailer.request_rejected_email(notification)
  end
end
