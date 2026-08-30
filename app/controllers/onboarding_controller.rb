# frozen_string_literal: true

class OnboardingController < ApplicationController
  skip_before_action :require_onboarding
  layout "centered"

  before_action :enforce_step_order

  def terms
    redirect_to user_terms_agreement_path
  end

  def accept_terms
    redirect_to user_terms_agreement_path
  end

  def profile; end

  def update_profile
    if current_user.update(profile_params)
      current_user.complete_onboarding!
      redirect_to session.delete(:return_to_after_authenticating) || default_authenticated_path
    else
      render :profile, status: :unprocessable_content
    end
  end

  private

  def enforce_step_order
    case action_name
    when "terms", "accept_terms"
      redirect_to default_authenticated_path if current_user.terms_accepted?
    when "profile", "update_profile"
      if !current_user.terms_accepted?
        redirect_to user_terms_agreement_path
      elsif !current_user.onboarding_pending?
        redirect_to default_authenticated_path
      end
    end
  end

  def profile_params
    params.expect(user: %i[name avatar])
  end
end
