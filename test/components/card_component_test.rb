require "test_helper"

class CardComponentTest < ViewComponent::TestCase
  def test_render_card_component
    render_inline(CardComponent.new(title: "Hello, card!", description: "This is a test card."))

    assert_component_rendered

    assert_text "Hello, card!"
    assert_text "This is a test card."
  end
end
