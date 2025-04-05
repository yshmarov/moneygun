# frozen_string_literal: true

class CreditsBadgeComponent < ViewComponent::Base
  attr_reader :organization, :counter, :link
  def initialize(organization:, counter: true, link: false)
    @organization = organization
    @counter = counter
    @link = link
  end

  def wrapper_classes
    default_classes = "font-medium border border-gray-200 bg-amber-400 dark:bg-amber-600 rounded-lg px-1"
    default_classes += " hover:bg-amber-500 dark:hover:bg-amber-700 active:scale-95 transition-all duration-200" if link
    default_classes
  end
end
