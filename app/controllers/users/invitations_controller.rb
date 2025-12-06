# frozen_string_literal: true

# incoming invitations to join an organization
class Users::InvitationsController < ApplicationController
  layout "devise", only: %i[show_accept accept]
  skip_before_action :authenticate_user!, only: %i[accept show_accept]
  before_action :set_invitation, only: %i[approve reject]
  before_action :set_user_from_token, only: %i[accept show_accept]

  def index
    organization_ids = current_user.organization_invitations.pending.select(:organization_id)
    @pagy, @organizations = pagy(Organization.where(id: organization_ids))
  end

  def approve
    @invitation.approve!
    redirect_back_or_to(user_invitations_path, notice: t("invitations.approve.success"))
  end

  def reject
    @invitation.reject!
    redirect_back_or_to(user_invitations_path, notice: t("invitations.reject.success"))
  end

  def show_accept
    if @user.nil?
      redirect_to new_user_session_path, alert: t(".invalid_token")
      return
    end
    @minimum_password_length = Devise.password_length.min
  end

  def accept
    if @user.nil?
      redirect_to new_user_session_path, alert: t(".invalid_token")
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
      render :show_accept, status: :unprocessable_content
    end
  end

  private

  def set_invitation
    @invitation = current_user.organization_invitations.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_invitations_path, alert: t("invitations.errors.not_found")
  end

  def set_user_from_token
    @user = User.find_by(invitation_token: params[:invitation_token])
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
