# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  renders_one :action_list
  renders_one :title_content

  def initialize(title: nil, subtitle: nil, full_width: true, hide_title_on_native: false)
    @title = title
    @full_width = full_width
    @subtitle = subtitle
    @hide_title_on_native = hide_title_on_native
  end

  attr_reader :title, :subtitle, :hide_title_on_native

  def width_class
    if @full_width == true
      "max-w-7xl w-full"
    else
      "lg:max-w-lg w-full"
    end
  end

  def hide_title_on_native_class
    "hotwire-native:hidden" if hide_title_on_native && helpers.turbo_native_app?
  end
end
