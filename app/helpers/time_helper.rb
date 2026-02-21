# frozen_string_literal: true

module TimeHelper
  # Renders a <time> tag with server-side fallback, upgraded to local time via Stimulus.
  # Replaces the `local_time` gem helper.
  #
  # Formats:
  #   :short — "Feb 17, 2026"
  #   :long  — "Feb 17, 2026, 10:00 AM"
  def local_time_tag(datetime, format: :short)
    return if datetime.nil?

    tag.time(
      datetime.utc.strftime(format == :short ? "%b %d, %Y" : "%b %d, %Y, %l:%M %p").strip,
      datetime: datetime.utc.iso8601,
      data: {
        controller: "local-time",
        local_time_format_value: format.to_s
      }
    )
  end
end
