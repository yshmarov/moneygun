# frozen_string_literal: true

#
# Uncomment this and change the path if necessary to include your own
# components.
# See https://github.com/heartcombo/simple_form#custom-components to know
# more about custom components.
Rails.root.glob("lib/components/**/*.rb").each { |f| require f }
#
# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Wrappers are used by the form builder to generate a
  # complete input. You can remove any component from the
  # wrapper, change the order or even add your own to the
  # stack. The options given below are used to wrap the
  # whole input.

  config.wrappers :default, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly

    b.wrapper :floating_label_wrapper, tag: :label, class: "floating-label" do |ba|
      ba.use :input, class: "input input-md w-full"
      ba.use :label, wrap_with: { tag: :span }
    end
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.optional :character_counter
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :textarea, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.optional :autogrow

    b.wrapper :floating_label_wrapper, tag: :label, class: "floating-label" do |ba|
      ba.use :input, class: "textarea textarea-md textarea-bordered w-full"
      ba.use :label, wrap_with: { tag: :span }
    end
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.optional :character_counter
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.include_default_input_wrapper_class = false
  config.item_wrapper_tag = :div
  config.collection_wrapper_tag = :div
  config.collection_wrapper_class = "flex flex-col gap-2"
  config.item_wrapper_class = "flex items-center gap-2"
  config.wrappers :vertical_radio, tag: "div", class: "form-control", error_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label-text"
    b.use :input, class: "radio mr-2"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :vertical_checkboxes, tag: "div", class: "form-control", error_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label-text"
    b.use :input, class: "checkbox mr-2"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :vertical_boolean, tag: "div", class: "form-control flex flex-col gap-1", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :boolean_wrapper, tag: :label, class: "flex items-center cursor-pointer gap-2 py-2" do |ba|
      ba.use :input, class: "toggle shrink-0"
      ba.wrapper :label_text_wrapper, tag: :span, class: "label-text" do |bt|
        bt.use :label_text
      end
    end
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :file_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly

    b.use :label, class: "label-text"
    b.use :input,
          class: "file-input file-input-md file-input-bordered w-full"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :date_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly

    b.use :label, class: "label-text"
    b.use :input, class: "input input-md w-full"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :datetime_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly

    b.use :label, class: "label-text"
    b.use :input, class: "input input-md w-full"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :range_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.optional :min_max

    b.use :label, class: "label-text"
    b.use :input, class: "range w-full"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :color_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly

    b.use :label, class: "label-text"
    b.use :input, class: "w-full h-10 rounded-lg cursor-pointer border-0 p-0"
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.wrappers :dropzone_input, tag: "div", class: "form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.use :label, class: "label-text"
    b.use :input
    b.use :full_error, wrap_with: { tag: "p", class: "mt-2 text-sm text-error", role: "alert" }
    b.use :hint, wrap_with: { tag: "div", class: "text-base-content/70 text-xs mt-1 whitespace-normal break-words w-full" }
  end

  config.default_wrapper = :default

  # Define the way to render check boxes / radio buttons with labels.
  # Defaults to :nested for bootstrap config.
  #   inline: input + label
  #   nested: label > input
  # Using :inline for boolean inputs since we handle the label wrapper ourselves
  config.boolean_style = :inline

  # Default class for buttons
  config.button_class = "btn"

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # Use :to_sentence to list all errors for each field.
  # config.error_method = :first

  # Default tag used for error notification helper.
  config.error_notification_tag = :div
  # CSS class to add for error notification helper.
  config.error_notification_class = "alert alert-error"
  config.label_text = ->(label, _required, _explicit_label) { label.to_s }

  config.default_form_class = nil

  # You can define which elements should obtain additional classes
  config.generate_additional_classes_for = []

  config.browser_validations = true

  config.wrapper_mappings = {
    string: :default,
    text: :textarea,
    boolean: :vertical_boolean,
    check_boxes: :vertical_checkboxes,
    radio_buttons: :vertical_radio,
    file: :file_input,
    date: :date_input,
    datetime: :datetime_input,
    time: :date_input,
    range: :range_input,
    color: :color_input,
    dropzone: :dropzone_input
    # prepend_string: :prepend_string,
    # append_string: :append_string,
  }
  config.boolean_label_class = "label-text"
end
