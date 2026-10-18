# frozen_string_literal: true

require "test_helper"

class CronCheckInTest < ActiveSupport::TestCase
  test "every scheduled job class resolves to its cron identifier" do
    Rails.application.config.good_job.cron.each do |identifier, entry|
      assert_equal identifier.to_s, CronCheckIn.identifier_for(entry[:class])
    end
  end
end
