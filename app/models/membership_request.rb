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
    return false if user.memberships.find_by(organization: organization).blank?

    errors.add(:base, I18n.t("membership_requests.errors.already_participant"))
    true
  end

  def request_access
    if organization.privacy_setting_public?
      user.memberships.create(organization:, role:)
    elsif organization.privacy_setting_restricted?
      if user.organization_requests.find_by(organization:).present?
        errors.add(:base, I18n.t("membership_requests.errors.already_requested"))
        return false
      end

      user.organization_requests.create(organization:, organization_role: role)
    end

    true
  end

  def role
    Membership.roles[:member]
  end
end
