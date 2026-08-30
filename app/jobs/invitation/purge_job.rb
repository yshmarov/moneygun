# frozen_string_literal: true

class Invitation::PurgeJob < ApplicationJob
  def perform
    Invitation.expired.where(created_at: ..30.days.ago).delete_all
  end
end
