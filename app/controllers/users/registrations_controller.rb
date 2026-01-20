# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  rate_limit to: 50, within: 3.minutes, only: :create, with: -> { redirect_to new_user_registration_url, alert: t("shared.errors.rate_limit") }

  def create
    super do
      refer resource if resource.persisted?
    end
  end

  def destroy
    # Check if user owns organizations with other members
    if resource.owned_organizations.any? { |org| org.memberships.where.not(user_id: resource.id).exists? }
      redirect_to edit_user_registration_path, alert: t(".cannot_delete_owns_org")
      return
    end

    # Check if user owns organizations with active subscriptions
    if resource.owned_organizations.any?(&:has_access?)
      redirect_to edit_user_registration_path, alert: t(".cannot_delete_active_subscription")
      return
    end

    # Archive memberships in other orgs (where user is not owner)
    resource.memberships.where.not(organization_id: resource.owned_organization_ids).find_each(&:archive!)

    super
  end
end
