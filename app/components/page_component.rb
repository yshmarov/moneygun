# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  renders_one :action_list

  def initialize(title:, content_container: false, full_width: true)
    @title = title
    @content_container = content_container
    @full_width = full_width
  end

  attr_reader :title

  def content_container_class
    default_classes = "space-y-4"
    container_classes = "border rounded-lg p-4 shadow"
    default_classes + " " + container_classes if @content_container == true
  end

  def width_class
    if @full_width == true
      "md:w-2/3 w-full"
    else
      "max-w-md w-full"
    end
  end
end
