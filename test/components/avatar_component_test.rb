# frozen_string_literal: true

require "test_helper"

class AvatarComponentTest < ViewComponent::TestCase
  test "renders accessible initials when no image is available" do
    render_inline AvatarComponent.new(alt: "Ada Lovelace", initials: "al")

    assert_selector "svg[role='img'][aria-label='Ada Lovelace']", text: "AL"
  end

  test "renders an image when a source is available" do
    render_inline AvatarComponent.new(src: "/avatar.png", alt: "Ada Lovelace")

    assert_selector "img[src='/avatar.png'][alt='Ada Lovelace']"
  end
end
