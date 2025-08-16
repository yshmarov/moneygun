# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Default class for buttons
  config.button_class = "du-btn du-btn-primary"

  # Define the default class of the input wrapper of the boolean input.
  config.boolean_label_class = ""

  # How the label text should be generated altogether with the required text.
  config.label_text = ->(label, required, _explicit_label) { "#{label} #{required}" }

  # Define the way to render check boxes / radio buttons with labels.
  config.boolean_style = :inline

  # You can wrap each item in a collection of radio/check boxes with a tag
  config.item_wrapper_tag = :div

  # Defines if the default input wrapper class should be included in radio
  # collection wrappers.
  config.include_default_input_wrapper_class = false

  # CSS class to add for error notification helper.
  config.error_notification_class = "du-alert du-alert-error"

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # :to_sentence to list all errors for each field.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = "du-input-error"
  config.input_field_valid_class = "du-input-success"
  config.label_class = "du-label"

  # vertical forms
  #
  # vertical default_wrapper
  config.wrappers :vertical_form, tag: "div", class: "du-form-control" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input,
          class: "du-input du-input-bordered w-full", error_class: "du-input-error", valid_class: "du-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: "div", class: "du-form-control", error_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: "div", class: "flex items-center" do |ba|
      ba.use :input,
             class: "du-checkbox du-checkbox-primary"
    end
    b.wrapper tag: "div", class: "ml-3" do |bb|
      bb.use :label, class: "du-label", error_class: "text-error"
      bb.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm" }
      bb.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm" }
    end
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, item_wrapper_class: "flex items-center",
                                        item_label_class: "du-label ml-3", tag: "div", class: "du-form-control" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "du-label",
                           error_class: "text-error" do |ba|
      ba.use :label_text
    end
    b.use :input,
          class: "du-radio du-radio-primary", error_class: "du-radio-error", valid_class: "du-radio-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical file input
  config.wrappers :vertical_file, tag: "div", class: "du-form-control" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-file-input du-file-input-bordered w-full", error_class: "du-file-input-error",
                  valid_class: "du-file-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical multi select
  config.wrappers :vertical_multi_select, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.wrapper tag: "div", class: "flex gap-2" do |ba|
      ba.use :input, class: "du-select du-select-bordered", error_class: "du-select-error", valid_class: "du-select-success"
    end
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical date input
  config.wrappers :vertical_date, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-input du-input-bordered w-full", error_class: "du-input-error", valid_class: "du-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical time input
  config.wrappers :vertical_time, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-input du-input-bordered w-full", error_class: "du-input-error", valid_class: "du-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical date time
  config.wrappers :vertical_datetime, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-input du-input-bordered w-full", error_class: "du-input-error", valid_class: "du-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical date time zone
  config.wrappers :vertical_datetime_local, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-input du-input-bordered w-full", error_class: "du-input-error", valid_class: "du-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical select
  config.wrappers :vertical_select, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-select du-select-bordered w-full", error_class: "du-select-error", valid_class: "du-select-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # vertical range
  config.wrappers :vertical_range, tag: "div", class: "du-form-control", error_class: "", valid_class: "" do |b|
    b.use :html5
    b.optional :readonly
    b.optional :step
    b.use :label, class: "du-label", error_class: "text-error"
    b.use :input, class: "du-range du-range-primary", error_class: "du-range-error", valid_class: "du-range-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "du-text-base-content/70 text-sm mt-1" }
  end

  # The default wrapper to be used by the FormBuilder.
  config.default_wrapper = :vertical_form

  # Custom wrappers for input types. This should be a hash containing an input
  # type as key and the wrapper used for the input.
  config.wrapper_mappings = {
    boolean: :vertical_boolean,
    check_boxes: :vertical_collection,
    collection: :vertical_collection,
    date: :vertical_date,
    datetime: :vertical_datetime,
    file: :vertical_file,
    radio_buttons: :vertical_collection,
    range: :vertical_range,
    select: :vertical_select,
    time: :vertical_time,
    datetime_local: :vertical_datetime_local
  }
end
