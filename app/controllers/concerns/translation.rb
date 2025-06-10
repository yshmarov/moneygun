module Translation
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  private

  def set_locale(&action)
    locale = determine_locale
    update_locale_for_user_and_cookies(locale)
    I18n.with_locale(locale, &action)
  rescue I18n::InvalidLocale
    fallback_locale = I18n.default_locale
    update_locale_for_user_and_cookies(fallback_locale)
    I18n.with_locale(fallback_locale, &action)
  end

  def determine_locale
    if params[:locale].present? && valid_locale?(params[:locale])
      params[:locale]
    else
      current_user&.language || cookies[:locale] || I18n.default_locale
    end
  end

  def valid_locale?(locale)
    I18n.available_locales.include?(locale.to_sym)
  end

  def update_locale_for_user_and_cookies(locale)
    cookies[:locale] = locale
    current_user.update(locale:) if user_signed_in?
  end
end
