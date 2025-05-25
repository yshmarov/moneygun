class PageComponent < ViewComponent::Base
  renders_one :action_list

  def initialize(title:, content_container: false, full_width: false)
    @title = title
    @content_container = content_container
    @full_width = full_width
  end

  attr_reader :title

  def content_container_class
    default_classes = "space-y-4"
    container_classes = "border rounded-lg p-4 shadow"
    return [ default_classes, container_classes ].join(" ") if @content_container == true

    default_classes
  end

  def width_class
    if @full_width == true
      "max-w-7xl w-full"
    else
      "lg:max-w-xl w-full"
    end
  end
end
