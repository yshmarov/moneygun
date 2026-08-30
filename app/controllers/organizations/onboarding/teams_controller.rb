# frozen_string_literal: true

class Organizations::Onboarding::TeamsController < Organizations::Onboarding::BaseController
  def show
    @memberships = @organization.memberships.active.includes(:user)
    @invitations = @organization.invitations.pending.order(created_at: :desc)
  end
end
