# frozen_string_literal: true

class SamlAuthRequest::CleanupJob < ApplicationJob
  def perform
    SamlAuthRequest.cleanup
  end
end
