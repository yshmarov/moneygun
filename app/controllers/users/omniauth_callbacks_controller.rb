# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :google_onetap

  def callback
    provider = params[:provider].to_sym
    handle_auth provider
  end

  def google_onetap
    unless g_csrf_token_valid?
      redirect_to new_user_session_path, alert: I18n.t("devise.omniauth_callbacks.failure")
      return
    end

    payload = GoogleIdTokenVerifier.verify(params[:credential])

    unless payload["email_verified"]
      redirect_to new_user_session_path, alert: I18n.t("devise.omniauth_callbacks.failure")
      return
    end

    auth_hash = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: payload["sub"],
      info: { name: payload["name"], email: payload["email"], image: payload["picture"] }
    )

    user = User.from_omniauth(auth_hash)

    if user.persisted?
      if user.saved_change_to_id?
        session[:new_user] = true
        refer user
      end
      sign_in_and_redirect user, event: :authentication
    else
      redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
    end
  rescue JWT::DecodeError
    redirect_to new_user_session_path, alert: I18n.t("devise.omniauth_callbacks.failure")
  end

  def failure
    redirect_to new_user_registration_url, alert: I18n.t("devise.omniauth_callbacks.failure")
  end

  private

  def handle_auth(kind)
    auth_payload = request.env["omniauth.auth"]

    if user_signed_in?
      identity = Identity.create_or_update_from_omniauth(auth_payload, current_user)
      unless identity.persisted?
        flash[:alert] = I18n.t("users.identities.errors.failed_to_connect",
                               provider: Identity::AUTH_PROVIDERS[kind][:name],
                               errors: identity.errors.full_messages.join(", "))
      end
      redirect_to user_identities_path
    else
      user = User.from_omniauth(auth_payload)
      if user.persisted?
        if user.saved_change_to_id?
          session[:new_user] = true
          refer user
        end
        sign_in_and_redirect user, event: :authentication, remember: true
      else
        session["devise.auth_data"] = auth_payload.except(:extra)
        redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
      end
    end
  end

  def g_csrf_token_valid?
    token = cookies["g_csrf_token"]
    token.present? && token == params["g_csrf_token"]
  end
end
