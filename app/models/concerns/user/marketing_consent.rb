# frozen_string_literal: true

module User::MarketingConsent
  extend ActiveSupport::Concern

  def marketing_consent
    marketing_consent_at.present?
  end
  alias marketing_consent? marketing_consent

  def marketing_consent=(value)
    consented = ActiveModel::Type::Boolean.new.cast(value)
    return if consented == marketing_consent

    self.marketing_consent_at = consented ? Time.current : nil
  end
end
