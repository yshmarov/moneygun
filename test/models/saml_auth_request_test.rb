# frozen_string_literal: true

require "test_helper"

class SamlAuthRequestTest < ActiveSupport::TestCase
  test "a matching in-flight request can be consumed once" do
    connection = organizations(:one).create_sso_connection!
    SamlAuthRequest.start("request-1", sso_connection_id: connection.id)

    assert SamlAuthRequest.consume("request-1", sso_connection_id: connection.id)
    assert_not SamlAuthRequest.consume("request-1", sso_connection_id: connection.id)
  end
end
