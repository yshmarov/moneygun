# frozen_string_literal: true

module Organization::Onboarding
  extend ActiveSupport::Concern

  def onboarding_step_completed?(key)
    metadata.dig("onboarding", "steps", key.to_s).present?
  end

  def complete_onboarding_step!(key, membership: nil)
    data = metadata.deep_dup
    steps = (data["onboarding"] ||= {})["steps"] ||= {}
    steps[key.to_s] ||= { "completed_at" => Time.current.iso8601, "membership_id" => membership&.id }.compact
    update!(metadata: data)
  end
end
