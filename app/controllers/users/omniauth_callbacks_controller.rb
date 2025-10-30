# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  Devise.omniauth_configs.each_key do |provider|
    define_method provider do
      handle_auth provider
    end
  end

  def failure
    redirect_to new_user_registration_url, alert: I18n.t("devise.omniauth_callbacks.failure")
  end

  private

  def handle_auth(kind)
    auth_payload = request.env["omniauth.auth"]

    if user_signed_in?
      # User is already logged in, add OAuth account to current user
      connected_account = ConnectedAccount.create_or_update_from_omniauth(auth_payload, current_user)
      if connected_account.persisted?
        flash[:notice] = I18n.t("devise.omniauth_callbacks.success", kind: ConnectedAccount::PROVIDER_CONFIG[kind][:name])
      else
        flash[:alert] = "Failed to connect #{ConnectedAccount::PROVIDER_CONFIG[kind][:name]} account: #{connected_account.errors.full_messages.join(", ")}"
      end
      redirect_to user_connected_accounts_path
    else
      user = User.from_omniauth(auth_payload)
      if user.persisted?
        if user.saved_change_to_id?
          session[:new_user] = true if user.saved_change_to_id?
          refer user
        end
        flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: ConnectedAccount::PROVIDER_CONFIG[kind][:name]
        sign_in_and_redirect user, event: :authentication
      else
        session["devise.auth_data"] = auth_payload.except(:extra)
        redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
      end
    end
  end
end
