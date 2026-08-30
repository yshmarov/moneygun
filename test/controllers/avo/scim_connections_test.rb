# frozen_string_literal: true

require "test_helper"

class Avo::ScimConnectionsTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:one)
    @connection = ScimConnection.create!(organization: organizations(:one))
  end

  test "index" do
    get "/admin/avo/resources/scim_connections"

    assert_response :success
  end

  test "show never exposes the token digest" do
    get "/admin/avo/resources/scim_connections/#{@connection.id}"

    assert_response :success
    assert_no_match @connection.token_digest, response.body
  end
end
