# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "destroying organization owner with no other members destroys organization" do
    users(:unassociated)
    # Create a fresh user with a solo organization
    new_user = User.create!(
      email: "solo-owner@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    organization = new_user.owned_organizations.first
    assert organization.present?
    assert_equal 1, organization.memberships.count

    assert_difference "Organization.count", -1 do
      new_user.destroy
    end
  end

  test "destroying organization owner with other members fails" do
    organization = organizations(:one)
    user = users(:one)

    # Add another member
    organization.memberships.create!(user: users(:two), role: Membership.roles[:member])

    assert_no_difference "Organization.count" do
      assert_no_difference "Membership.count" do
        assert_not user.destroy
      end
    end

    assert_includes user.errors[:base], I18n.t("errors.models.user.cannot_delete_owns_org_with_members", org_name: organization.name)
  end

  test "destroying organization member (non-owner) archives their membership" do
    organization = organizations(:one)
    user = users(:unassociated)
    membership = organization.memberships.create!(user:, role: Membership.roles[:member])

    # User also has their own default organization from creation
    # We need to destroy that first or archive those memberships
    user.owned_organizations.each(&:destroy!)

    assert_no_difference "Organization.count" do
      # Membership count stays the same because membership is archived (nullified), not destroyed
      assert_no_difference "Membership.count" do
        user.destroy
      end
    end

    membership.reload
    assert_nil membership.user_id
    assert membership.suspended?
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

  test "from_omniauth auto-confirms new OAuth users" do
    auth_payload = mock_omniauth_payload("google_oauth2", "987654321", "newuser@example.com")

    user = User.from_omniauth(auth_payload)
    assert user.confirmed?
    assert_not_nil user.confirmed_at
  end

  test "from_omniauth confirms existing unconfirmed users" do
    # Create an unconfirmed user (skip organization creation by setting invitation_created_at)
    user = User.create!(
      email: "username@example.com",
      password: "password123",
      password_confirmation: "password123",
      confirmed_at: nil
    )
    assert_not user.confirmed?

    # Sign in via OAuth
    auth_payload = mock_omniauth_payload("google_oauth2", "987654321", "username@example.com")
    result_user = User.from_omniauth(auth_payload)

    assert_equal user, result_user
    assert result_user.confirmed?
    assert_not_nil result_user.confirmed_at
  end

  test "after user creation, default organization is created" do
    assert_difference "Organization.count", 1 do
      assert_difference "Membership.count", 1 do
        user = User.create!(
          email: "test@example.com",
          password: "password123",
          password_confirmation: "password123"
        )

        organization = user.owned_organizations.first
        assert_not_nil organization
        assert_equal organization.owner.email.split("@").first, organization.name
        assert_equal user, organization.owner

        membership = organization.memberships.first
        assert_equal user, membership.user
        assert_equal "admin", membership.role
      end
    end
  end

  test "invited user does not receive a default organization" do
    inviter = users(:one)
    organization = organizations(:one)

    assert_no_difference "Organization.count" do
      assert_no_difference "Membership.count" do
        assert_difference "User.count", 1 do
          membership_invitation = MembershipInvitation.new(email: "invited-user@example.com", organization:, inviter:)
          membership_invitation.save
          user = User.find_by(email: "invited-user@example.com")
          assert user.persisted?
          assert user.invitation_created_at.present?
          assert_empty user.owned_organizations
        end
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
