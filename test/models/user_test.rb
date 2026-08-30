# frozen_string_literal: true

require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "issuing a sign-in code retires the previous sign-in or sign-up code" do
    user = users(:one)
    superseded = user.send_magic_link(for: :sign_up)

    replacement = user.send_magic_link(for: :sign_in)

    assert_not MagicLink.exists?(superseded.id)
    assert MagicLink.exists?(replacement.id)
    assert_equal 1, user.magic_links.where(purpose: %w[sign_in sign_up]).count
  end

  test "issuing a sign-in code preserves codes for other purposes" do
    user = users(:one)
    sudo = user.send_magic_link(for: :sudo)
    email_change = user.send_magic_link(for: :email_change, new_email: "changed@example.com")

    user.send_magic_link(for: :sign_in)

    assert MagicLink.exists?(sudo.id)
    assert MagicLink.exists?(email_change.id)
  end

  test "magic-link replacement happens inside a row lock" do
    user = users(:one)
    locked = false
    user.define_singleton_method(:with_lock) do |*, &block|
      locked = true
      block.call
    end

    user.send_magic_link

    assert locked
  end

  test "organization owners must transfer or delete their organizations before closing their account" do
    user = users(:one)

    assert_not user.destroy
    assert_predicate user, :persisted?
    assert_includes user.undeletable_reasons, :owns_organizations
  end

  test "destroying a non-owner member preserves organization" do
    organization = organizations(:one)
    user = users(:unassociated)
    organization.memberships.create!(user: user)

    assert_no_difference "Organization.count" do
      assert_difference "Membership.count", -1 do
        user.destroy
      end
    end
  end

  test "new user is created without a default organization" do
    assert_no_difference ["Organization.count", "Membership.count"] do
      user = User.create!(email: "standalone@example.com")

      assert_empty user.owned_organizations
      assert_empty user.organizations
    end
  end

  test "email is normalized and unique without case sensitivity" do
    user = User.create!(email: " Mixed@Example.COM ")

    assert_equal "mixed@example.com", user.email
    assert_not User.new(email: "MIXED@example.com").valid?
  end
end
