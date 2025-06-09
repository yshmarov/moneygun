# frozen_string_literal: true

require "test_helper"

class TabsComponentTest < ViewComponent::TestCase
  def test_component_renders_with_tabs
    tabs = [
      { key: :tab1, label: "Tab 1", path: "/tab1" },
      { key: :tab2, label: "Tab 2", path: "/tab2" }
    ]

    render_inline(TabsComponent.new(active_tab: :tab1, tabs: tabs))

    assert_selector "nav", count: 1
    assert_selector "a", count: 2
    assert_text "Tab 1"
    assert_text "Tab 2"
  end

  def test_component_renders_active_tab_with_correct_classes
    tabs = [
      { key: :tab1, label: "Tab 1", path: "/tab1" },
      { key: :tab2, label: "Tab 2", path: "/tab2" }
    ]

    render_inline(TabsComponent.new(active_tab: :tab1, tabs: tabs))

    assert_selector "a[href='/tab1']", class: "border-primary text-primary"
    assert_selector "a[href='/tab2']", class: "border-transparent"
  end

  def test_component_renders_with_badge_count
    tabs = [
      { key: :tab1, label: "Tab 1", path: "/tab1", badge_count: 5 }
    ]

    render_inline(TabsComponent.new(active_tab: :tab1, tabs: tabs))

    assert_selector ".du-badge", text: "5"
  end

  def test_component_renders_with_icon
    tabs = [
      { key: :tab1, label: "Tab 1", path: "/tab1", icon: "<i class='icon'></i>".html_safe }
    ]

    render_inline(TabsComponent.new(active_tab: :tab1, tabs: tabs))

    assert_selector "i.icon"
  end

  def test_component_respects_condition
    tabs = [
      { key: :tab1, label: "Tab 1", path: "/tab1", condition: true },
      { key: :tab2, label: "Tab 2", path: "/tab2", condition: false }
    ]

    render_inline(TabsComponent.new(active_tab: :tab1, tabs: tabs))

    assert_text "Tab 1"
    assert_no_text "Tab 2"
  end
end
