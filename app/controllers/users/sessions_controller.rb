# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  rate_limit to: 50, within: 3.minutes, only: :create, with: -> { redirect_to new_user_session_url, alert: t("shared.errors.rate_limit") }

  def create
    params[:user][:remember_me] = "1"
    super
  end
end
