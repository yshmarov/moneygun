# frozen_string_literal: true

class Users::InvitationAcceptancesController < ApplicationController
  layout "devise"
  skip_before_action :authenticate_user!

  # Rate limit to prevent brute force token guessing
  rate_limit to: 20, within: 3.minutes, only: %i[show update], with: -> { redirect_to new_user_session_url, alert: t("shared.errors.rate_limit") }

  before_action :set_user_from_token, only: %i[show update]
  before_action :ensure_valid_invitation, only: %i[show update]

  def show
    @minimum_password_length = Devise.password_length.min
  end

  def update
    # Use database lock to prevent race conditions
    @user.with_lock do
      # Double-check invitation hasn't been accepted (race condition protection)
      if @user.invitation_accepted_at.present?
        redirect_to new_user_session_path, alert: t("users.invitation_acceptances.show.invalid_token")
        return
      end

      if @user.update(invitation_acceptance_params)
        sign_in(@user)
        redirect_to user_invitations_path, notice: t(".success")
      else
        @minimum_password_length = Devise.password_length.min
        render :show, status: :unprocessable_content
      end
    end
  end

  private

  def set_user_from_token
    # Normalize token to prevent timing attacks
    token = params[:invitation_token].to_s
    @user = User.find_by(invitation_token: token) if token.present?
    # Always check expiration to normalize timing
    return unless @user&.invitation_created_at && @user.invitation_created_at < 7.days.ago

    @user = nil
  end

  def ensure_valid_invitation
    return if @user.present? && @user.invitation_accepted_at.blank?

    redirect_to new_user_session_path, alert: t("users.invitation_acceptances.show.invalid_token")
  end

  def invitation_acceptance_params
    password_params.merge(
      invitation_accepted_at: Time.current,
      invitation_token: nil,
      confirmed_at: Time.current
    )
  end

  def password_params
    params.expect(user: %i[password password_confirmation])
  end
end
