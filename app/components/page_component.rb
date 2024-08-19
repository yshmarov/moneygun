# frozen_string_literal: true

class PageComponent < ViewComponent::Base
  renders_one :action_list

  def initialize(title:)
    @title = title
  end

  attr_reader :title

end
