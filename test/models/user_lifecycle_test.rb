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
    user = User.create!(email: "retained@example.com", name: "Retained User")
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
    user = User.create!(email: "erasable@example.com")

    assert_difference "User.count", -1 do
      assert user.erase!
    end
  end

  test "redaction removes access and contact data while retaining attribution" do
    user = User.create!(
      email: "retained-lifecycle@example.com",
      name: "Retained User",
      locale: "en",
      metadata: { "preference" => "value" },
      marketing_consent: true
    )
    membership = organizations(:one).memberships.create!(user: user, role: "member")
    AuditLog.log!(organization: membership.organization, actor: membership, action: "project.reviewed", actor_kind: "member")
    original_email = user.email
    organizations(:two).invitations.create!(email: original_email, invited_by: users(:two))
    user.avatar.attach(io: file_fixture("avo-logo.png").open, filename: "avatar.png", content_type: "image/png")
    user.enable_two_factor!(ROTP::Base32.random)
    user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    user.magic_links.create!
    api_token = user.generate_token_for(:api)

    assert user.erase!

    user.reload
    assert_equal "redacted-#{user.id}@#{User::Redaction::REDACTED_EMAIL_DOMAIN}", user.email
    assert_nil user.display_email
    assert_nil user.locale
    assert_empty user.metadata
    assert_not user.marketing_consent?
    assert_not user.two_factor_enabled?
    assert_empty user.sessions
    assert_empty user.magic_links
    assert_not Invitation.for_email(original_email).exists?
    assert_nil User.find_by_token_for(:api, api_token)
    assert_equal "Retained User", user.name
    assert_predicate user.avatar, :attached?
    assert_predicate membership.reload, :deactivated?
  end

  test "account closure groups organizations by blocking reason" do
    user = User.create!(email: "blocked@example.com")
    owner = users(:two)
    organizations = ["Alpha lifecycle", "Beta lifecycle"].map do |name|
      organization = Organization.create!(name: name, owner: owner)
      organization.memberships.find_by!(user: owner).update_column(:role, "member") # rubocop:disable Rails/SkipsModelValidations
      organization.memberships.create!(user: user, role: "admin")
      organization
    end

    reason, interpolations = user.undeletable_reasons.sole

    assert_equal :sole_admin, reason
    assert_equal organizations.map(&:name).to_sentence, interpolations[:organizations]
    assert_not user.erase!
    assert_not_predicate user.reload, :redacted?
  end
end
