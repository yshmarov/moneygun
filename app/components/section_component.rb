# frozen_string_literal: true

class SectionComponent < ApplicationComponent
  renders_one :action_list
  renders_one :page_title, PageTitleComponent

  def initialize(title: nil, subtitle: nil, full_width: true)
    @title = title
    @full_width = full_width
    @subtitle = subtitle
  end

  attr_reader :title, :subtitle

  def width_class
    @full_width ? "max-w-7xl w-full" : "lg:max-w-2xl w-full"
  end
end
