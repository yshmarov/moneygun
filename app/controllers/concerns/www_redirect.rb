# frozen_string_literal: true

module WwwRedirect
  extend ActiveSupport::Concern

  included do
    before_action :redirect_www
  end

  private

  def redirect_www
    app_host = ENV.fetch("HOST", nil)
    return unless app_host
    return unless request.host == "www.#{app_host}"

    redirect_to "https://#{app_host}#{request.fullpath}", status: :moved_permanently, allow_other_host: true
  end
end
