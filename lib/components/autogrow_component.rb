# frozen_string_literal: true

# Autogrow component for SimpleForm textarea inputs
#
# Usage:
#   <%= f.input :description, as: :text, autogrow: true %>
#   <%= f.input :bio, as: :text, autogrow: true, autogrow_max_height: 10 %>
#
module Components
  module AutogrowComponent
    CONTROLLER_NAME = "simple-form--autogrow"

    def autogrow(_wrapper_options = nil)
      return nil unless options[:autogrow]
      return nil unless input_type == :text # Only works with textareas

      # Support both naming conventions
      raw_max_height = options[:autogrow_max_height] || options[:autogrow_max_height_value]
      max_height = raw_max_height.presence&.to_i
      # Only positive integers are valid max heights (0 or negative are ignored)
      has_valid_max_height = max_height.is_a?(Integer) && max_height.positive?

      # Merge autogrow data attributes into input_html_options
      # SimpleForm merges these into the input element
      input_html_options[:data] ||= {}

      # Add controller (preserve existing controllers)
      existing_controller = input_html_options[:data][:controller]
      controllers = [existing_controller, CONTROLLER_NAME].compact
      input_html_options[:data][:controller] = controllers.join(" ")

      # Add action (preserve existing actions)
      existing_action = input_html_options[:data][:action]
      actions = [existing_action, "input->#{CONTROLLER_NAME}#resize"].compact
      input_html_options[:data][:action] = actions.join(" ")

      # Add max height value if specified
      input_html_options[:data][:"#{CONTROLLER_NAME}-max-height-value"] = max_height if has_valid_max_height

      nil # Return nil as we're modifying input_html_options, not rendering content
    end
  end
end

SimpleForm.include_component(Components::AutogrowComponent)
