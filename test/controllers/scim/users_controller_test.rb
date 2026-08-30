# frozen_string_literal: true

require "test_helper"

class Scim::UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @organization = organizations(:one)
    @connection = @organization.create_scim_connection!
    @token = @connection.token
  end

  test "rejects missing credentials" do
    get "/scim/v2/Users", headers: headers(nil)
    assert_response :unauthorized
  end

  test "token scopes listings to its organization" do
    get "/scim/v2/Users", headers: headers(@token)

    assert_response :success
    ids = JSON.parse(response.body)["Resources"].map { |resource| resource["id"].to_i } # rubocop:disable Rails/ResponseParsedBody
    assert_equal @organization.memberships.pluck(:id).sort, ids.sort
  end

  test "provisions a new passwordless member without a throwaway organization" do
    assert_difference -> { User.count } => 1, -> { @organization.memberships.count } => 1,
                      -> { Organization.count } => 0 do
      post "/scim/v2/Users", params: payload("new@acme.example").to_json, headers: headers(@token)
    end

    assert_response :created
    membership = @organization.memberships.joins(:user).find_by!(users: { email: "new@acme.example" })
    assert_equal "scim", membership.provisioned_via
  end

  test "cannot deprovision the organization owner" do
    owner = @organization.memberships.find_by!(user: @organization.owner)

    delete "/scim/v2/Users/#{owner.id}", headers: headers(@token)

    assert_response :conflict
    assert_predicate owner.reload, :active?
  end

  test "deprovisions an ordinary member without deleting history" do
    member = @organization.memberships.create!(user: users(:two), role: "member")

    assert_no_difference "Membership.count" do
      delete "/scim/v2/Users/#{member.id}", headers: headers(@token)
    end

    assert_response :no_content
    assert_predicate member.reload, :deactivated?
  end

  private

  def headers(token)
    values = { "Content-Type" => "application/scim+json", "Accept" => "application/scim+json" }
    values["Authorization"] = "Bearer #{token}" if token
    values
  end

  def payload(email)
    {
      schemas: ["urn:ietf:params:scim:schemas:core:2.0:User"],
      userName: email,
      emails: [{ value: email, type: "work", primary: true }],
      active: true
    }
  end
end
