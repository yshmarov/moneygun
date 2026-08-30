# frozen_string_literal: true

class MembershipRequest
  include ActiveModel::Model

  attr_accessor :organization, :user

  validates :organization, presence: true
  validates :user, presence: true

  def save
    return false unless valid?

    return false if user_already_participant?

    return false if organization.privacy_setting_private?

    request_access
  end

  private

  def user_already_participant?
    return false unless user.memberships.active.exists?(organization: organization)

    errors.add(:base, I18n.t("membership_requests.errors.already_participant"))
    true
  end

  def request_access
    if organization.privacy_setting_public?
      membership = user.memberships.find_or_initialize_by(organization:)
      membership.deactivated_at = nil
      membership.save
    elsif organization.privacy_setting_restricted?
      if user.sent_join_requests.find_by(organization:).present?
        errors.add(:base, I18n.t("membership_requests.errors.already_requested"))
        return false
      end

      user.sent_join_requests.create(organization:)
    end

    true
  end
end
