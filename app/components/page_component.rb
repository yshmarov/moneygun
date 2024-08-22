# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  renders_one :action_list

  def initialize(title:, content_container: false)
    @title = title
    @content_container = content_container
  end

  attr_reader :title

  def conent_container_class
    "border rounded-lg p-4" if @content_container == true
  end
end
