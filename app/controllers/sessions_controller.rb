# frozen_string_literal: true

class SessionsController < ApplicationController
  require_unauthenticated_access except: :destroy
  invisible_captcha only: :create
  rate_limit to: 10, within: 3.minutes, only: :create, name: "ip",
             with: -> { redirect_to new_session_path, alert: t("shared.errors.rate_limit") }
  rate_limit to: 5, within: 15.minutes, only: :create, name: "email",
             by: -> { params[:email_address].to_s.strip.downcase.presence || request.remote_ip },
             with: -> { redirect_to new_session_path, alert: t("shared.errors.rate_limit") }

  layout "centered"

  def new
    @prefill_email_address = params[:email_address].presence || session.delete(:prefill_email_address) || cookies.encrypted[:remembered_email]
  end

  def create
    if SsoConnection.enforced_for_email(email_address)
      redirect_to new_sso_path(email_address: email_address)
      return
    end

    user = User.find_by(email: email_address)

    if user.nil?
      sign_up_with_magic_link
    elsif user.can_authenticate?
      redirect_to_session_magic_link user.send_magic_link
    else
      redirect_to_fake_session_magic_link email_address
    end
  end

  def destroy
    terminate_session

    respond_to do |format|
      format.html { redirect_to new_session_path }
      format.json { head :no_content }
    end
  end

  private

  def email_address
    params.expect(:email_address).strip.downcase
  end

  def sign_up_with_magic_link
    user = User.new(email: email_address)

    if user.save
      redirect_to_session_magic_link user.send_magic_link(for: :sign_up)
    else
      redirect_to_fake_session_magic_link email_address
    end
  end
end
