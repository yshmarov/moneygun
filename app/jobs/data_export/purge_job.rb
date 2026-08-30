# frozen_string_literal: true

class DataExport::PurgeJob < ApplicationJob
  def perform
    DataExport.expired.find_each(&:destroy!)
  end
end
