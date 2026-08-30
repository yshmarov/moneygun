# frozen_string_literal: true

require "test_helper"

class SessionTest < ActiveSupport::TestCase
  test "resumes a live signed session and touches activity" do
    session = users(:one).sessions.create!(last_seen_at: 1.hour.ago)
    previous_seen_at = session.last_seen_at

    resumed = Session.resume_from_cookie(session.signed_id)

    assert_equal session, resumed
    assert_operator resumed.reload.last_seen_at, :>, previous_seen_at
  end

  test "destroys a session after the idle timeout" do
    session = users(:one).sessions.create!(last_seen_at: (Session::IDLE_TIMEOUT + 1.day).ago)

    assert_nil Session.resume_from_cookie(session.signed_id)
    assert_not Session.exists?(session.id)
  end
end
