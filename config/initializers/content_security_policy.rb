# frozen_string_literal: true

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.script_src :self
    policy.style_src :self, :unsafe_inline
    policy.img_src :self, :data, :blob, :https
    policy.font_src :self, :data
    policy.connect_src :self, :https
    policy.frame_src :self
    policy.object_src :none
    policy.media_src :self, :https, :blob
    policy.base_uri :self
    policy.form_action :self, "https://checkout.stripe.com", "https://billing.stripe.com"
    policy.frame_ancestors :self
    policy.report_uri "/csp-reports"
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session[:csp_nonce] ||= SecureRandom.hex(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
  config.content_security_policy_report_only = false
end
