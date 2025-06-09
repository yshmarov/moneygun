module Translation
  extend ActiveSupport::Concern

  included do
    # before_action :set_locale
  end

  private

  def set_locale
    locale = determine_locale
    update_locale_for_user_and_cookies(locale)
    I18n.locale = locale
  rescue I18n::InvalidLocale
    fallback_locale = I18n.default_locale
    update_locale_for_user_and_cookies(fallback_locale)
    I18n.locale = fallback_locale
  end

  def determine_locale
    if params[:locale].present? && valid_locale?(params[:locale])
      params[:locale]
    else
      current_user&.locale || cookies[:locale] || I18n.default_locale
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
