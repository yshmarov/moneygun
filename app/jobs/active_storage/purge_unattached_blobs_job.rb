# frozen_string_literal: true

class ActiveStorage::PurgeUnattachedBlobsJob < ApplicationJob
  STALE_AGE = 24.hours

  def perform
    ActiveStorage::Blob.unattached.where(created_at: ...STALE_AGE.ago).find_each(&:purge_later)
  end
end
