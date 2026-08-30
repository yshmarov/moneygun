# frozen_string_literal: true

module TimeHelper
  # Renders a <time> tag with server-side fallback, upgraded to local time via Stimulus.
  # Replaces the `local_time` gem helper.
  #
  # Formats:
  #   :short      — "Feb 17, 2026"
  #   :short_time — "Feb 17, 10:00 AM"
  #   :long       — "Feb 17, 2026, 10:00 AM"
  def local_time_tag(datetime, format: :short)
    return if datetime.nil?

    strftime_pattern = case format
                       when :long       then "%b %d, %Y, %l:%M %p"
                       when :short_time then "%b %d, %l:%M %p"
                       else "%b %d, %Y"
                       end

    tag.time(
      datetime.utc.strftime(strftime_pattern).strip,
      datetime: datetime.utc.iso8601,
      data: {
        controller: "local-time",
        local_time_format_value: format.to_s
      }
    )
  end
end
