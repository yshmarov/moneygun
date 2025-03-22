class BreadcrumbsComponent < ViewComponent::Base
  def initialize(current_path:)
    @current_path = current_path
    @segments = parse_path(current_path)
  end

  private

  def render?
    @segments.any?
  end

  def parse_path(path)
    parts = path.split("/").reject(&:empty?)
    return [] if parts.empty?

    # Extract the organization parts
    return [] if parts.size < 2 || parts[0] != "organizations"
    org_id = parts[1]

    # Skip org parts and dashboard
    parts = parts[2..-1] || []
    parts.shift if parts.first == "dashboard"
    return [] if parts.empty?

    # Build segments with paths
    base_path = "/organizations/#{org_id}"
    current_path = base_path

    parts.map.with_index do |part, index|
      current_path += "/#{part}"
      {
        name: name_for_segment(part, index),
        path: current_path
      }
    end
  end

  def name_for_segment(part, index)
    if [ "edit", "new" ].include?(part)
      part.capitalize
    elsif index.even?
      part.humanize
    else
      part # ID or other non-resource segment
    end
  end
end
