# frozen_string_literal: true

require "test_helper"

class SsoConnectionTest < ActiveSupport::TestCase
  test "discovery and enforcement require a verified domain" do
    connection = organizations(:one).create_sso_connection!
    domain = connection.sso_domains.create!(domain: "acme.example")

    assert_nil SsoConnection.discoverable_for_email("person@acme.example")

    domain.update_column(:verified_at, Time.current) # rubocop:disable Rails/SkipsModelValidations
    connection.update_columns(enabled: true, enforced: true) # rubocop:disable Rails/SkipsModelValidations

    assert_equal connection, SsoConnection.discoverable_for_email("person@acme.example")
    assert_equal connection, SsoConnection.enforced_for_email("person@acme.example")
    assert_not User.new(email: "person@acme.example").can_authenticate_with_magic_link?
  end

  test "JIT does not adopt an existing account without an organization tie" do
    connection = organizations(:one).create_sso_connection!(jit_provisioning: true)
    connection.sso_domains.create!(domain: "superails.com", verified_at: Time.current)

    assert_nil connection.sign_in_membership(users(:two).email)
  end

  test "JIT creates a new user only inside the asserted organization" do
    connection = organizations(:one).create_sso_connection!(jit_provisioning: true)
    connection.sso_domains.create!(domain: "acme.example", verified_at: Time.current)
    Current.sso_connection = connection

    assert_difference -> { User.count } => 1, -> { Organization.count } => 0 do
      membership = connection.sign_in_membership("new@acme.example", name: "New Person")
      assert_equal connection.organization, membership.organization
      assert_equal "sso", membership.provisioned_via
    end
  end
end
