# frozen_string_literal: true

class Organizations::Onboarding::BaseController < Organizations::BaseController
  layout "centered"
  before_action :authorize_onboarding

  private

  def authorize_onboarding
    authorize @organization, :edit?
  end
end
