# frozen_string_literal: true

class PageTitleComponent < ApplicationComponent
  def initialize(*trail, back_to: nil, heading: true)
    @trail = trail
    @back_to = back_to
    @heading = heading
  end

  private

  attr_reader :trail, :back_to, :heading

  def trail_item(item, last:)
    label, path = item

    body = if path && !last
             link_to(label, path)
           elsif last && heading
             tag.h1(label, class: "text-base font-medium")
           else
             label
           end

    tag.li body, class: ("font-medium" if last), aria: { current: ("page" if last) }
  end
end
