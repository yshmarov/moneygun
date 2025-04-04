# frozen_string_literal: true

class CreditsBadgeComponent < ViewComponent::Base
  attr_reader :organization, :counter, :link
  def initialize(organization:, counter: true, link: false)
    @organization = organization
    @counter = counter
    @link = link
  end
end
