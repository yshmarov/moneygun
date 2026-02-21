# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  email = Rails.application.config_for(:settings).dig(:site, :email)
  name = Rails.application.config_for(:settings).dig(:site, :name)

  default from: email_address_with_name(email, name)
  layout "mailer"

  prepend_view_path "app/views/mailers"
end
