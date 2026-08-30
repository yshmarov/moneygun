# frozen_string_literal: true

class Organizations::Onboarding::SubscriptionsController < Organizations::Onboarding::BaseController
  def show
    return redirect_to organization_dashboard_path(@organization) if @organization.has_access? || !StripePrice.configured?

    @trial_eligible = @organization.trial_eligible?
  end
end
