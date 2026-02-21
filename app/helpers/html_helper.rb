# frozen_string_literal: true

module HtmlHelper
  def format_html(html)
    doc = Loofah::HTML5::DocumentFragment.parse(html)
    doc.scrub!(AutoLinkScrubber.new)
    doc.scrub!(ExternalLinkScrubber.new)
    doc.to_html.html_safe
  end
end
