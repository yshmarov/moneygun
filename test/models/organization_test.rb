# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "set a default payment processor" do
    user = users(:one)
    organization = Organization.create!(name: "Test", owner: user)
    assert_equal "stripe", organization.payment_processor.processor
  end

  test "privacy_setting cannot be public when no logo is attached" do
    user = users(:one)
    organization = Organization.new(
      name: "Test Org",
      owner: user,
      privacy_setting: :public
    )

    assert_not organization.valid?
    assert_includes organization.errors[:privacy_setting], "requires logo to be discoverable for restricted and public organizations"

    organization.logo.attach(
      io: Rails.root.join("test/fixtures/files/avo-logo.png").open,
      filename: "logo.png",
      content_type: "image/png"
    )

    assert organization.valid?

    organization.privacy_setting = :restricted
    assert organization.valid?

    organization.privacy_setting = :public
    assert organization.valid?

    organization.save!

    assert_includes Organization.discoverable, organization
  end
end
