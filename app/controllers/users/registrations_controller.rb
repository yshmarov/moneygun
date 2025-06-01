class Users::RegistrationsController < Devise::RegistrationsController
  rate_limit to: 50, within: 3.minutes, only: :create, with: -> { redirect_to new_user_registration_url, alert: t("shared.errors.rate_limit") }

  def create
    super do
      refer resource if resource.persisted?
    end
  end
end
