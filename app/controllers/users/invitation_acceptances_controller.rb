# frozen_string_literal: true

class Users::InvitationAcceptancesController < ApplicationController
  layout "devise"
  skip_before_action :authenticate_user!

  before_action :set_user_from_token, only: %i[show update]

  def show
    if @user.nil?
      redirect_to new_user_session_path, alert: t(".invalid_token")
      return
    end
    @minimum_password_length = Devise.password_length.min
  end

  def update
    if @user.nil?
      redirect_to new_user_session_path, alert: t("users.invitation_acceptances.show.invalid_token")
      return
    end

    if @user.update(password_params)
      @user.update!(
        invitation_accepted_at: Time.current,
        invitation_token: nil,
        confirmed_at: Time.current
      )
      sign_in(@user)
      redirect_to user_invitations_path, notice: t(".success")
    else
      @minimum_password_length = Devise.password_length.min
      render :show, status: :unprocessable_content
    end
  end

  private

  def set_user_from_token
    @user = User.find_by(invitation_token: params[:invitation_token])
  end

  def password_params
    params.expect(user: %i[password password_confirmation])
  end
end
