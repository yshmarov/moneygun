# frozen_string_literal: true

# Loofah scrubber that adds target="_blank" and rel="noopener noreferrer" to all anchor tags.
#
# Designed to run after AutoLinkScrubber so both user-created and auto-linked URLs open in new tabs.
class ExternalLinkScrubber < Loofah::Scrubber
  def initialize
    @direction = :top_down
  end

  def scrub(node)
    if node.name == "a" && node["href"]
      node["target"] = "_blank"
      node["rel"] = "noopener noreferrer"
    end

    Loofah::Scrubber::CONTINUE
  end
end
