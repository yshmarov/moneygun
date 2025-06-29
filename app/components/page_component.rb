class PageComponent < ViewComponent::Base
  renders_one :action_list
  renders_one :title_content

  def initialize(title: nil, subtitle: nil, full_width: true)
    @title = title
    @full_width = full_width
    @subtitle = subtitle
  end

  attr_reader :title, :subtitle

  def width_class
    if @full_width == true
      "max-w-7xl w-full"
    else
      "lg:max-w-xl w-full"
    end
  end
end
