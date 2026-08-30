# frozen_string_literal: true

module Authentication
  extend ActiveSupport::Concern

  class SsoAccessWithdrawn < StandardError; end

  included do
    before_action :require_authentication
    after_action :ensure_development_magic_link_not_leaked
    helper_method :current_user, :user_signed_in?, :authenticated?, :email_address_pending_authentication
    etag { Current.user&.id }
  end

  class_methods do
    def require_unauthenticated_access(**)
      allow_unauthenticated_access(**)
      before_action(:redirect_authenticated_user, **)
    end

    def allow_unauthenticated_access(**)
      skip_before_action(:require_authentication, **)
      before_action(:resume_session, **)
    end
  end

  private

  def require_authentication
    resume_session || authenticate_by_bearer_token || request_authentication
  end

  def resume_session
    session_record = Session.resume_from_cookie(cookies[:session_token], cookies: cookies)
    activate_session(session_record) if session_record
  end

  def authenticate_by_bearer_token
    return unless request.authorization.to_s.starts_with?("Bearer ")

    authenticate_or_request_with_http_token do |token|
      user = User.find_by_token_for(:api, token)
      next unless user&.can_authenticate?

      Current.user = user
      Current.actor_kind = "api"
    end
  end

  def activate_session(session_record)
    Current.session = session_record
    cookies[:session_token] = {
      value: session_record.signed_id,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: Session::IDLE_TIMEOUT.from_now
    }
  end

  def terminate_session
    signed_out_user = Current.session&.user
    Current.session&.destroy
    cookies.delete(:session_token)
    log_user_event(signed_out_user, "user.signed_out") if signed_out_user
    reset_session
  end

  def establish_authenticated_session(user, authentication:)
    session_record = Session.transaction do
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip, authentication: authentication).tap do
        record_successful_authentication!(user, authentication)
      end
    end

    activate_session(session_record)
    remember_email(user)
    true
  rescue SsoAccessWithdrawn
    false
  end

  def remember_email(user)
    cookies.encrypted[:remembered_email] = {
      value: user.email,
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: 1.year.from_now
    }
  end

  def log_user_event(user, action, metadata: {})
    AuditLog.log_for_memberships!(user.memberships.active, action: action, metadata: metadata)
  end

  def sign_in_or_verify_two_factor(user, authentication: {})
    if user.two_factor_enabled?
      store_pending_two_factor_token(user, authentication: authentication)
      redirect_to new_session_two_factor_path
    elsif establish_authenticated_session(user, authentication: authentication)
      redirect_after_sign_in
    else
      redirect_to new_sso_path, alert: t("sessions.sso.denied")
    end
  end

  def record_successful_authentication!(user, authentication)
    return if authentication.blank?

    case authentication["method"]
    when "magic_link"
      AuditLog.log_for_memberships!(user.memberships.active, action: "user.signed_in")
    when "sso"
      record_successful_sso_authentication!(user, authentication)
    else
      raise ArgumentError, "Unknown authentication method"
    end
  end

  def record_successful_sso_authentication!(user, authentication)
    connection = SsoConnection.enabled.find_by(id: authentication.fetch("connection_id"))
    membership = connection && user.memberships.active.find_by(
      id: authentication.fetch("membership_id"),
      organization: connection.organization
    )
    raise SsoAccessWithdrawn unless membership

    connection.update_column(:last_login_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
    AuditLog.log!(
      organization: connection.organization,
      mini_app: "organization",
      actor: membership,
      action: "user.signed_in_via_sso",
      actor_kind: "sso",
      metadata: { sso_connection_id: connection.id }
    )
  end

  def current_user
    Current.user
  end

  def authenticated?
    Current.user.present?
  end

  def user_signed_in?
    authenticated?
  end

  def redirect_authenticated_user
    redirect_to default_authenticated_path if authenticated?
  end

  def request_authentication
    if request.format.json?
      head :unauthorized
    else
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end
  end

  def redirect_after_sign_in
    redirect_to next_onboarding_path || session.delete(:return_to_after_authenticating) || default_authenticated_path
  end

  def require_onboarding
    return unless user_signed_in?

    current_user.complete_onboarding! if current_user.terms_accepted? && current_user.onboarding_pending? && current_user[:name].present?
    redirect_to next_onboarding_path if next_onboarding_path
  end

  def next_onboarding_path
    return unless user_signed_in?
    return user_terms_agreement_path unless current_user.terms_accepted?

    profile_onboarding_path if current_user.onboarding_pending? && current_user[:name].blank?
  end

  def redirect_to_session_magic_link(magic_link)
    serve_development_magic_link(magic_link)
    store_pending_authentication_token(magic_link)
    redirect_to session_magic_link_path
  end

  def redirect_to_fake_session_magic_link(email_address)
    redirect_to_session_magic_link MagicLink.new(
      user: User.new(email: email_address),
      code: MagicLink::Code.generate(MagicLink::CODE_LENGTH),
      expires_at: MagicLink::EXPIRATION_TIME.from_now
    )
  end

  def serve_development_magic_link(magic_link)
    return unless Rails.env.development?

    flash[:magic_link_code] = magic_link.code
    response.set_header("X-Magic-Link-Code", magic_link.code)
  end

  def ensure_development_magic_link_not_leaked
    return if Rails.env.development?

    raise "Leaking magic link via flash in #{Rails.env}?" if flash[:magic_link_code].present?
  end

  def store_pending_authentication_token(magic_link)
    cookies.encrypted[:pending_authentication_token] = {
      value: pending_authentication_token_verifier.generate(magic_link.user.email, expires_at: magic_link.expires_at),
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: magic_link.expires_at
    }
  end

  def email_address_pending_authentication
    pending_authentication_token_verifier.verified(cookies.encrypted[:pending_authentication_token])
  end

  def pending_authentication_token_verifier
    Rails.application.message_verifier(:pending_authentication)
  end

  def clear_pending_authentication_token
    cookies.delete(:pending_authentication_token)
  end

  def store_pending_two_factor_token(user, authentication: {})
    cookies.encrypted[:pending_two_factor_token] = {
      value: pending_two_factor_token_verifier.generate({ user_id: user.id, authentication: authentication }, expires_at: 5.minutes.from_now),
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: 5.minutes.from_now
    }
  end

  def user_pending_two_factor
    User.find_by(id: pending_two_factor_payload&.fetch("user_id", nil))
  end

  def authentication_pending_two_factor
    pending_two_factor_payload&.fetch("authentication", {}) || {}
  end

  def pending_two_factor_payload
    return @pending_two_factor_payload if defined?(@pending_two_factor_payload)

    value = pending_two_factor_token_verifier.verified(cookies.encrypted[:pending_two_factor_token])
    @pending_two_factor_payload = value.is_a?(Hash) ? value.stringify_keys : { "user_id" => value, "authentication" => {} }
  end

  def clear_pending_two_factor_token
    cookies.delete(:pending_two_factor_token)
  end

  def pending_two_factor_token_verifier
    Rails.application.message_verifier(:pending_two_factor)
  end
end
