# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  # TODO: memberships with associated downstream records should not be deletable
  test "destroying organization owner destroys organization" do
    organization = organizations(:one)
    user = users(:one)

    assert_difference "Organization.count", -1 do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end

    # TODO: this should not be a valid state!
    assert organization.memberships.none?
  end

  test "destroying organization member (non-owner) does not destroy organization" do
    organization = organizations(:one)
    user = users(:unassociated)
    organization.memberships.create!(user:, role: Membership.roles[:admin])

    assert_no_difference "Organization.count" do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end

    assert organization.memberships.any?
  end

  test "from_omniauth returns existing user when connected account exists" do
    user = users(:one)
    user.connected_accounts.create!(
      provider: "google_oauth2",
      uid: "123456789",
      payload: { "info" => { "email" => "test@example.com" } }
    )

    auth_payload = mock_omniauth_payload("google_oauth2", "123456789", "test@example.com")

    result_user = User.from_omniauth(auth_payload)

    assert_equal user, result_user
    assert result_user.persisted?
  end

  test "from_omniauth creates new user when no connected account exists" do
    auth_payload = mock_omniauth_payload("google_oauth2", "987654321", "newuser@example.com")

    assert_difference "User.count", 1 do
      assert_difference "ConnectedAccount.count", 1 do
        user = User.from_omniauth(auth_payload)
        assert user.persisted?
        assert_equal "newuser@example.com", user.email
        assert user.connected_accounts.any?
      end
    end
  end

  private

  def mock_omniauth_payload(provider, uid, email)
    OpenStruct.new(
      provider: provider,
      uid: uid,
      info: OpenStruct.new(email: email),
      credentials: OpenStruct.new(
        token: "mock_token",
        refresh_token: "mock_refresh_token",
        expires_at: Time.current.to_i
      ),
      to_h: {
        "provider" => provider,
        "uid" => uid,
        "info" => { "email" => email },
        "credentials" => {
          "token" => "mock_token",
          "refresh_token" => "mock_refresh_token",
          "expires_at" => Time.current.to_i
        }
      }
    )
  end
end
