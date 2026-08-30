# frozen_string_literal: true

class MembershipMailer < ApplicationMailer
  def invitation(invitation)
    @invitation = invitation
    @organization = invitation.organization
    @action_url = user_invitation_url(invitation)
    mail(to: invitation.email, subject: t(".subject", organization_name: @organization.name))
  end

  def invitation_email(notification)
    setup(notification)
    # Use email_url for invitation acceptance, not the regular notification url
    @action_url = notification.email_url if notification.respond_to?(:email_url)
    invitor_email = @recipient.invited_by&.email || t(".someone")
    mail(to: @recipient.email, subject: t(".subject", invitor_email: invitor_email, organization_name: @organization.name))
  end

  def request_accepted_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: t(".subject", organization_name: @organization.name))
  end

  def request_rejected_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: t(".subject", organization_name: @organization.name))
  end

  def removal_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: notification.message)
  end

  def organization_deleted(notification)
    @organization_name = notification.params[:organization_name]
    mail(to: notification.recipient.email, subject: t(".subject", organization_name: @organization_name))
  end

  private

  def setup(notification)
    @organization = notification.params[:organization]
    @message = notification.message
    @recipient = notification.recipient
    @action_url = notification.url
  end
end
