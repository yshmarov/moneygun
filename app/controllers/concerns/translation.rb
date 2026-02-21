# frozen_string_literal: true

module Translation
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale(&)
    locale = determine_locale
    persist_locale(locale)
    I18n.with_locale(locale, &)
  end

  def determine_locale
    explicit_locale = params[:locale] || current_user&.locale || cookies[:locale]

    if valid_locale?(explicit_locale)
      explicit_locale.to_sym
    else
      locale_from_accept_language || I18n.default_locale
    end
  end

  def locale_from_accept_language
    header = request.env["HTTP_ACCEPT_LANGUAGE"]
    return nil if header.blank?

    # Parse Accept-Language header (e.g., "uk,pl;q=0.9,en;q=0.8")
    # and return the best matching available locale
    locales_with_quality = header.split(",").map do |entry|
      entry = entry.strip
      locale, quality = entry.split(";")
      locale = locale.strip.downcase.gsub("-", "_")
      q = quality ? quality.strip.delete_prefix("q=").to_f : 1.0
      [locale, q]
    end

    locales_with_quality.sort_by { |_, q| -q }.each do |locale, _|
      # Try exact match first (e.g., "uk"), then language prefix (e.g., "en_us" -> "en")
      [locale, locale.split("_").first].each do |candidate|
        return candidate.to_sym if valid_locale?(candidate)
      end
    end

    nil
  end

  def valid_locale?(locale)
    locale.present? && I18n.available_locales.include?(locale.to_sym)
  end

  # Only persist locale when the user made an explicit choice (URL param, cookie, or DB).
  # Accept-Language detection is transient — re-evaluated each request so it stays
  # in sync with the browser's language setting without locking users into a cookie.
  def persist_locale(locale)
    explicit_choice = params[:locale].present? || current_user&.locale.present? || cookies[:locale].present?
    return unless explicit_choice

    cookies[:locale] = { value: locale.to_s, expires: 1.year.from_now }

    return unless user_signed_in? && current_user.locale.to_s != locale.to_s

    current_user.update(locale: locale)
  end
end
