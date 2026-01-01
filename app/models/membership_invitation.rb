# frozen_string_literal: true

class MembershipInvitation
  include ActiveModel::Model

  attr_accessor :email, :organization, :inviter

  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def save
    return false unless valid?

    user = find_or_invite_user
    return false unless user&.valid?

    create_access_request(user)
  end

  private

  def find_or_invite_user
    User.find_by(email: email) || User.invite!({ email: }, inviter)
  end

  def create_access_request(user)
    membership = user.memberships.find_by(organization: organization)
    if membership.present?
      errors.add(:base, "#{email} is already a member of this organization.")
    else
      invitation = organization.sent_invitations.create(user:)
      return true if invitation.persisted?

      invitation.errors.messages.each_value do |messages|
        messages.each { |message| errors.add(:base, message) }
      end
    end
    false
  end
end
