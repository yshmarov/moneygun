class PageComponent < ViewComponent::Base
  renders_one :action_list

  def initialize(title:, full_width: false)
    @title = title
    @full_width = full_width
  end

  attr_reader :title

  def width_class
    if @full_width == true
      "max-w-7xl w-full"
    else
      "lg:max-w-xl w-full"
    end
  end
end
