# frozen_string_literal: true

class MagicLink::CleanupJob < ApplicationJob
  def perform
    MagicLink.cleanup
  end
end
