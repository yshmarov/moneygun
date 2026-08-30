# frozen_string_literal: true

module CurrentRequest
  extend ActiveSupport::Concern

  included do
    before_action :set_current_request
  end

  private

  def set_current_request
    Current.request_context = {
      request_id: request.request_id,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    }
  end
end
