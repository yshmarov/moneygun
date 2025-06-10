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
  end

  def determine_locale
    requested_locale = params[:locale] || current_user&.locale || cookies[:locale]

    if valid_locale?(requested_locale)
      requested_locale.to_sym
    else
      I18n.default_locale
    end
  end

  def valid_locale?(locale)
    locale.present? && I18n.available_locales.include?(locale.to_sym)
  end

  def update_locale_for_user_and_cookies(locale)
    cookies[:locale] = { value: locale.to_s, expires: 1.year.from_now }

    if user_signed_in? && current_user.locale.to_s != locale.to_s
      current_user.update(locale: locale)
    end
  end
end
