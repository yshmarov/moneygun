# frozen_string_literal: true

module CharacterCounterComponent
  def character_counter(_wrapper_options = nil)
    return nil unless options[:character_counter]

    # Support both naming conventions
    raw_limit = options[:character_count_limit] || options[:character_counter_limit]
    limit = raw_limit.presence&.to_i
    has_valid_limit = limit.is_a?(Integer) && limit.positive?

    data_attributes = {
      controller: "simple-form--character-counter"
    }
    # Stimulus converts nested controller names: simple_form/character_counter -> simple-form--character-counter
    # Values use the same pattern with double dashes
    data_attributes[:"simple-form--character-counter-input-selector-value"] = "input, textarea"
    data_attributes[:"simple-form--character-counter-limit-value"] = limit if has_valid_limit

    initial_display = has_valid_limit ? "0/#{limit}" : "0"

    content_tag(
      :span,
      class: "text-sm text-base-content/70 mt-1 block",
      data: data_attributes
    ) do
      content_tag(:span, initial_display, data: { "simple-form--character-counter-target": "display" })
    end
  end
end

SimpleForm.include_component(CharacterCounterComponent)
