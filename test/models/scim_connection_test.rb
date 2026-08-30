# frozen_string_literal: true

require "test_helper"

class ScimConnectionTest < ActiveSupport::TestCase
  test "stores only a digest and can rotate its one-time token" do
    connection = ScimConnection.create!(organization: organizations(:one))
    original = connection.token

    assert_equal connection, ScimConnection.authenticate(original)
    assert_not_equal original, connection.token_digest

    replacement = connection.regenerate_token!
    assert_nil ScimConnection.authenticate(original)
    assert_equal connection, ScimConnection.authenticate(replacement)
    assert_equal replacement.last(4), connection.token_last_four
  end
end
