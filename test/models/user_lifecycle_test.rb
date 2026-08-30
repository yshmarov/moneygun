# frozen_string_literal: true

require "test_helper"

class UserLifecycleTest < ActiveSupport::TestCase
  test "banning terminates sessions and prevents authentication" do
    user = users(:one)
    user.sessions.create!

    assert_difference -> { user.sessions.count }, -1 do
      user.ban!
    end

    assert_predicate user, :banned?
    assert_not user.can_authenticate?
    user.unban!
    assert user.can_authenticate?
  end

  test "marketing consent records and preserves the consent time" do
    user = users(:one)
    user.update!(marketing_consent: true)
    consented_at = user.marketing_consent_at

    user.update!(marketing_consent: true)
    assert_equal consented_at, user.reload.marketing_consent_at

    user.update!(marketing_consent: false)
    assert_not user.marketing_consent?
  end

  test "account with retained audit history is redacted instead of destroyed" do
    Current.sso_connection = SsoConnection.new
    user = User.create!(email: "retained@example.com", name: "Retained User")
    Current.sso_connection = nil
    membership = organizations(:one).memberships.create!(user: user)
    AuditLog.log!(organization: membership.organization, actor: membership, action: "user.signed_in", actor_kind: "member")

    assert_no_difference "User.count" do
      assert user.erase!
    end

    assert_predicate user.reload, :redacted?
    assert_predicate membership.reload, :deactivated?
    assert_nil user.display_email
    assert_not user.can_authenticate?
  end

  test "account without retained data is deleted" do
    Current.sso_connection = SsoConnection.new
    user = User.create!(email: "erasable@example.com")
    Current.sso_connection = nil

    assert_difference "User.count", -1 do
      assert user.erase!
    end
  end
end
