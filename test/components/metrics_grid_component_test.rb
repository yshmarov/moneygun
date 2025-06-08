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
    assert_text "$1,500.00"
    assert_text "1,250"
  end

  def test_component_formats_money_correctly
    metrics = [
      {
        title: "Revenue",
        value: 150050,
        type: :money,
        subtitle: "This month"
      }
    ]

    render_inline(MetricsGridComponent.new(metrics: metrics))

    assert_text "$1,500.50"
  end

  def test_component_formats_numbers_correctly
    metrics = [
      {
        title: "Users",
        value: 12500,
        type: :number,
        subtitle: "Active users"
      }
    ]

    render_inline(MetricsGridComponent.new(metrics: metrics))

    assert_text "12,500"
  end

  def test_component_includes_animated_number_attributes
    metrics = [
      {
        title: "Revenue",
        value: 150000,
        type: :money,
        subtitle: "This month"
      }
    ]

    render_inline(MetricsGridComponent.new(metrics: metrics))

    assert_selector "[data-controller='animated-number']"
    assert_selector "[data-animated-number-end-value='1500.0']"
  end
end
