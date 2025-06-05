class User < ApplicationRecord
  include User::Authentication
  include User::Multitenancy
  has_referrals

  after_create :create_default_organization, if: -> { Rails.application.config_for(:settings).dig(:only_personal_accounts) }

  def self.ransackable_attributes(auth_object = nil)
    %w[id email]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  private

  def create_default_organization
    organization = organizations.first_or_create(name: "Default", owner: self)
    organization.memberships.first.update(role: Membership.roles[:admin])
  end
end
