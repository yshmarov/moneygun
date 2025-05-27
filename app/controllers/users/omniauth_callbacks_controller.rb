class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  Devise.omniauth_configs.keys.each do |provider|
    define_method provider do
      handle_auth provider
    end
  end

  private

  def handle_auth(kind)
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      session[:new_user] = true if user.saved_change_to_id?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: kind
      sign_in_and_redirect user, event: :authentication
    else
      session["devise.auth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to new_user_registration_url, alert: "Something went wrong. Please try again"
  end
end
