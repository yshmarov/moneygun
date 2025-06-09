# frozen_string_literal: true

require "test_helper"

class MetricsGridComponentTest < ViewComponent::TestCase
  def test_component_renders_with_metrics
    metrics = [
      {
        title: "Revenue",
        value: 150000,
        type: :money,
        subtitle: "This month"
      },
      {
        title: "Users",
        value: 1250,
        type: :number,
        subtitle: "Active users"
      }
    ]

    render_inline(MetricsGridComponent.new(metrics: metrics))

    assert_selector ".grid", count: 1
    assert_selector ".du-card", count: 2
    assert_text "Revenue"
    assert_text "Users"
  end
end
