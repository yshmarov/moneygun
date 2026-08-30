# frozen_string_literal: true

require "test_helper"

class MagicLinkTest < ActiveSupport::TestCase
  test "generates an expiring numeric code" do
    magic_link = users(:one).magic_links.create!

    assert_match(/\A\d{6}\z/, magic_link.code)
    assert_operator magic_link.expires_at, :>, 14.minutes.from_now
  end

  test "consume is single-use and purpose-scoped" do
    magic_link = users(:one).magic_links.create!(purpose: :sign_in)

    assert_nil MagicLink.consume(magic_link.code, purpose: :sudo)
    assert_equal magic_link.id, MagicLink.consume(magic_link.code, purpose: :sign_in).id
    assert_nil MagicLink.consume(magic_link.code, purpose: :sign_in)
  end
end
