# frozen_string_literal: true

class Organizations::MembershipsController < Organizations::BaseController
  before_action :set_membership, only: %i[edit update destroy reactivate]

  def index
    authorize Membership
    manage = Current.membership.admin?
    available_tabs = manage ? %w[members pending deactivated] : %w[members]
    @current_tab = params[:tab].presence_in(available_tabs) || "members"
    @role_filter = Array(params[:role]).map(&:to_s) & Membership.roles.keys

    scoped = @organization.memberships.includes(:user)
    pending_invitations = @organization.invitations.pending

    @memberships = case @current_tab
                   when "deactivated" then scoped.deactivated.order(deactivated_at: :desc)
                   when "pending" then Membership.none
                   else scoped.active.order(role: :asc, created_at: :asc)
                   end
    @memberships = @memberships.where(role: @role_filter) if @role_filter.present?
    @invitations = @current_tab == "pending" ? pending_invitations.order(created_at: :desc) : Invitation.none
    @invitations = @invitations.where(role: @role_filter) if @role_filter.present?

    @members_count = scoped.active.count
    @pending_count = manage ? pending_invitations.count : 0
    @deactivated_count = manage ? scoped.deactivated.count : 0
  end

  def edit; end

  def update
    if @membership.update(membership_params)
      flash[:notice] = t(".success")
      respond_to do |format|
        format.html { redirect_to organization_memberships_path(@organization) }
        format.turbo_stream { render turbo_stream: turbo_stream.redirect_to(organization_memberships_path(@organization)) }
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @membership.deactivate
      if @membership.user == current_user
        redirect_to organizations_path, notice: t(".you_have_left_the_organization")
      else
        redirect_to organization_memberships_path(@organization), notice: t(".access_removed")
      end
    else
      redirect_to organization_memberships_path(@organization), alert: @membership.errors.full_messages.to_sentence.presence || t(".failed")
    end
  end

  def reactivate
    authorize @membership, :reactivate?
    if @membership.reactivate
      redirect_to organization_memberships_path(@organization), notice: t(".success")
    else
      redirect_to organization_memberships_path(@organization), alert: @membership.errors.full_messages.to_sentence
    end
  end

  private

  def set_membership
    @membership = @organization.memberships.find(params.expect(:id))
    authorize @membership
  end

  def membership_params
    params.expect(membership: [:role])
  end
end
