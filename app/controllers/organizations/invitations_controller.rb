# frozen_string_literal: true

class Organizations::InvitationsController < Organizations::BaseController
  RATE_LIMIT_PER_HOUR = 30

  before_action :enforce_rate_limit, only: :create
  before_action :set_invitation, only: %i[destroy resend]

  def index
    authorize Invitation
    @pagy, @invitations = pagy(@organization.invitations.pending.order(created_at: :desc))
  end

  def new
    authorize Invitation
    @invitation = @organization.invitations.new(role: "member")
  end

  def create
    authorize Invitation
    @invitation = @organization.invitations.new(invitation_params)
    @invitation.invited_by = current_user

    if @invitation.save
      @invitation.log_created!(actor: Current.membership)
      @invitation.deliver
      respond_to do |format|
        format.html { redirect_to organization_memberships_path(@organization, tab: "pending") }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_memberships_path(@organization, tab: "pending")) }
      end
    else
      render :new, status: :unprocessable_content
    end
  end

  def destroy
    authorize @invitation
    @invitation.revoke!(actor: Current.membership)
    redirect_to organization_memberships_path(@organization, tab: "pending")
  rescue Invitation::TransitionError
    redirect_to organization_memberships_path(@organization, tab: "pending"), alert: t(".unavailable")
  end

  def resend
    authorize @invitation, :create?

    if @invitation.resendable?
      @invitation.resend!
      redirect_to organization_memberships_path(@organization, tab: "pending"), notice: t(".success")
    else
      redirect_to organization_memberships_path(@organization, tab: "pending"), alert: t(".cooldown")
    end
  end

  private

  def set_invitation
    @invitation = @organization.invitations.pending.find_by!(token: params.expect(:id))
  end

  def invitation_params
    params.expect(invitation: %i[email role])
  end

  def enforce_rate_limit
    return if @organization.invitations.where(created_at: 1.hour.ago..).count < RATE_LIMIT_PER_HOUR

    skip_authorization
    redirect_to organization_invitations_path(@organization), alert: t(".rate_limited", limit: RATE_LIMIT_PER_HOUR)
  end
end
