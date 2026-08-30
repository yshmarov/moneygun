# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "with_access includes complimentary and subscribed organizations" do
    complimentary = organizations(:one)
    complimentary.update!(admin_granted_access: true)
    subscribed = organizations(:two)
    subscribed.set_payment_processor :fake_processor, allow_fake: true
    subscribed.payment_processor.subscribe(plan: "fake")

    assert_includes Organization.with_access, complimentary
    assert_includes Organization.with_access, subscribed
    assert_not_includes Organization.with_access, organizations(:three)
  end

  test "complimentary access yields to a live subscription and survives cancellation" do
    organization = organizations(:one)
    organization.update!(admin_granted_access: true)
    organization.set_payment_processor :fake_processor, allow_fake: true
    subscription = organization.payment_processor.subscribe(plan: "fake")

    assert_not_predicate organization, :complimentary_access?

    subscription.update!(ends_at: 1.week.from_now)

    assert_predicate organization.reload, :complimentary_access?
    assert_predicate organization, :has_access?
  end
  test "active subscriptions prevent destruction" do
    organization = organizations(:one)
    organization.stubs(:active_subscription?).returns(true)

    assert_not organization.destroy
    assert_includes organization.errors[:base], "has an active subscription"
  end

  test "erase notifies other active members" do
    organization = organizations(:one)
    recipient = users(:unassociated)
    organization.memberships.create!(user: recipient, role: "member")
    Current.user = organization.owner

    assert_difference -> { Noticed::Event.where(type: "Membership::OrganizationDeletedNotifier").count } do
      assert organization.erase!
    end
  ensure
    Current.reset
  end

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
