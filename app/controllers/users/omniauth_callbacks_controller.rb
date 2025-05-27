class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth "Google"
  end

  def handle_auth(kind)
    user = User.from_omniauth(request.env["omniauth.auth"])
    if user.persisted?
      session[:new_user] = true if user.saved_change_to_id?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: kind
      sign_in_and_redirect user, event: :authentication
    else
      session["devise.auth_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to root_path, alert: user.errors.full_messages.join("\n")
    end
  end

  def failure
    redirect_to root_path, alert: "Something went wrong. Please try again"
  end
end
