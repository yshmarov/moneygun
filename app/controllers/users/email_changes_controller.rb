# frozen_string_literal: true

class Users::EmailChangesController < ApplicationController
  rate_limit to: 10, within: 15.minutes, only: :create,
             with: -> { redirect_to edit_user_path, alert: t("users.email_changes.rate_limited") }
  before_action -> { require_sudo(:change_email) }, only: %i[new create]
  before_action :ensure_pending_email_change, only: %i[show update]

  layout "centered", only: :show

  def show; end
  def new; end

  def create
    new_email = params.expect(:email)&.strip&.downcase

    if new_email == current_user.email
      redirect_to edit_user_path, alert: t("users.email_changes.same_email")
    elsif (error = email_validation_error(new_email))
      redirect_to edit_user_path, alert: error
    else
      magic_link = current_user.send_magic_link(for: :email_change, new_email: new_email)
      write_pending_email_change_token(magic_link)
      serve_development_magic_link(magic_link)
      redirect_to user_email_change_path
    end
  end

  def update
    magic_link = current_user.magic_links.consume(params.expect(:code), purpose: :email_change, new_email: pending_email_change)

    if magic_link
      complete_email_change(magic_link)
    else
      redirect_to user_email_change_path, alert: t("users.email_changes.invalid_code")
    end
  end

  private

  def ensure_pending_email_change
    redirect_to edit_user_path if pending_email_change.blank?
  end

  def complete_email_change(magic_link)
    clear_pending_email_change_token
    previous_email = current_user.email
    current_user.update!(email: magic_link.new_email, email_verified_at: Time.current)
    current_user.sessions.where.not(id: Current.session.id).destroy_all
    AuditLog.log_for_memberships!(current_user.memberships,
                                  action: "user.email_changed",
                                  metadata: { changes: { email: [previous_email, current_user.email] } })
    redirect_to user_path, notice: t("users.email_changes.success")
  end

  def write_pending_email_change_token(magic_link)
    cookies.encrypted[:pending_email_change_token] = {
      value: email_change_verifier.generate(magic_link.new_email, expires_at: magic_link.expires_at),
      httponly: true,
      same_site: :lax,
      secure: Rails.env.production?,
      expires: magic_link.expires_at
    }
  end

  def pending_email_change
    email_change_verifier.verified(cookies.encrypted[:pending_email_change_token])
  end
  helper_method :pending_email_change

  def clear_pending_email_change_token
    cookies.delete(:pending_email_change_token)
  end

  def email_change_verifier
    Rails.application.message_verifier(:pending_email_change)
  end

  def email_validation_error(email)
    return t("users.email_changes.email_taken") if User.exists?(email: email)

    test_user = User.new(email: email)
    test_user.validate
    test_user.errors.full_messages_for(:email).first
  end
end
