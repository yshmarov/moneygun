# frozen_string_literal: true

class Organizations::Onboarding::ProfilesController < Organizations::Onboarding::BaseController
  def show; end

  def update
    if @organization.update(profile_params)
      @organization.complete_onboarding_step!(:profile, membership: Current.membership)
      redirect_to organization_onboarding_team_path(@organization)
    else
      render :show, status: :unprocessable_content
    end
  end

  private

  def profile_params
    uploads_only(params.expect(organization: %i[name website logo privacy_setting]), @organization, :logo)
  end
end
