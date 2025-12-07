# frozen_string_literal: true

# Character counter component for SimpleForm inputs
#
# Usage:
#   <%= f.input :name, character_counter: true %>
#   <%= f.input :description, character_counter: true, character_counter_limit: 500 %>
#
module Components
  module CharacterCounterComponent
    CONTROLLER_NAME = "simple-form--character-counter"

    def character_counter(_wrapper_options = nil)
      return nil unless options[:character_counter]

      # Support both naming conventions
      raw_limit = options[:character_count_limit] || options[:character_counter_limit]
      limit = raw_limit.presence&.to_i
      # Only positive integers are valid limits (0 or negative are ignored)
      has_valid_limit = limit.is_a?(Integer) && limit.positive?

      data_attributes = {
        controller: CONTROLLER_NAME
      }
      # Stimulus converts nested controller names: simple_form/character_counter -> simple-form--character-counter
      # Values use the same pattern with double dashes
      data_attributes[:"#{CONTROLLER_NAME}-input-selector-value"] = "input, textarea"
      data_attributes[:"#{CONTROLLER_NAME}-limit-value"] = limit if has_valid_limit

      initial_display = has_valid_limit ? "0/#{limit}" : "0"

      content_tag(
        :span,
        class: "text-xs text-base-content/70 mt-1 block text-right",
        role: "status",
        "aria-live": "polite",
        data: data_attributes
      ) do
        content_tag(:span, initial_display, data: { "#{CONTROLLER_NAME}-target": "display" })
      end
    end
  end
end

SimpleForm.include_component(Components::CharacterCounterComponent)
