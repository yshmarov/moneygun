# frozen_string_literal: true

class Session::CleanupJob < ApplicationJob
  def perform
    Session.cleanup
  end
end
