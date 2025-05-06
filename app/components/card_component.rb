# frozen_string_literal: true

class CardComponent < ViewComponent::Base
  renders_one :image
  renders_many :actions

  attr_reader :title, :description

  def initialize(title:, description:)
    @title = title
    @description = description
  end
end
