module User::DefaultOrganization
  extend ActiveSupport::Concern

  included do
    after_create :create_default_organization, unless: :b2b_enabled?
  end

  private

  def create_default_organization
    return if b2b_enabled?
    return if organizations.any?

    organization = Organization.create!(
      name: "#{email.split('@').first.humanize}'s Organization",
      owner: self
    )

    organization.memberships.create!(user: self, role: Membership.roles[:admin])
  end

  def b2b_enabled?
    Rails.application.config_for(:settings).dig(:app_features, :b2b) == true
  end
end
