# frozen_string_literal: true

module User::Onboarding
  extend ActiveSupport::Concern

  def terms_accepted?
    Agreements.pending_version("user_terms", subject: self).nil?
  end

  def onboarding_completed?
    onboarding_completed_at.present?
  end

  def onboarding_pending?
    !onboarding_completed?
  end

  def complete_onboarding!
    update!(onboarding_completed_at: Time.current) if onboarding_pending?
  end
end
