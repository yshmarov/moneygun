require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "set a default payment processor" do
    user = users(:one)
    organization = Organization.create!(name: "Test", owner: user)
    assert_equal "stripe", organization.payment_processor.processor
  end
end
