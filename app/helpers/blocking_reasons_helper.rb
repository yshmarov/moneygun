# frozen_string_literal: true

module BlockingReasonsHelper
  def blocking_reasons_sentence(reasons, scope:)
    reasons.map { |reason, interpolations| t("#{scope}.#{reason}", **interpolations.to_h) }.to_sentence
  end
end
