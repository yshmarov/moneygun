# frozen_string_literal: true

require "test_helper"

class LogrageTest < ActiveSupport::TestCase
  test "keeps filenames and download tokens out of Active Storage paths" do
    event = ActiveSupport::Notifications::Event.new(
      "process_action.action_controller", nil, nil, "id",
      { path: "/rails/active_storage/blobs/token/private-name.pdf", request_id: "request" }
    )

    assert_equal "/rails/active_storage/[FILTERED]", Rails.application.config.lograge.custom_options.call(event)[:path]
  end
end
