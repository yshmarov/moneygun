# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.config_for(:settings).dig(:site, :email)
  layout "mailer"
end
