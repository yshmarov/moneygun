class MembershipMailer < ApplicationMailer
  def invitation_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: t(".subject", organization_name: @organization.name))
  end

  def request_accepted_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: t(".subject", organization_name: @organization.name))
  end

  def request_rejected_email(notification)
    setup(notification)
    mail(to: @recipient.email, subject: t(".subject", organization_name: @organization.name))
  end

  private

  def setup(notification)
    @organization = notification.params[:organization]
    @message = notification.message
    @recipient = notification.recipient
    @action_url = notification.url
  end
end
