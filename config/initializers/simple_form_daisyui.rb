# frozen_string_literal: true

# Use this setup block to configure all options available in SimpleForm.
SimpleForm.setup do |config|
  # Default class for buttons
  config.button_class = "btn btn-primary"

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
  config.error_notification_class = "alert alert-error"

  # Method used to tidy up errors. Specify any Rails Array method.
  # :first lists the first message for each field.
  # :to_sentence to list all errors for each field.
  config.error_method = :to_sentence

  # add validation classes to `input_field`
  config.input_field_error_class = "input-error"
  config.input_field_valid_class = "input-success"
  config.label_class = "label"

  # Tell browsers whether to use the native HTML5 validations (novalidate form option).
  # These validations are enabled in SimpleForm's internal config but disabled by default
  # in this configuration, which is recommended due to some quirks from different browsers.
  # To stop SimpleForm from generating the novalidate option, enabling the HTML5 validations,
  # change this configuration to true.
  config.browser_validations = true

  # vertical forms
  #
  # vertical default_wrapper
  config.wrappers :vertical_form, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input,
          class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical input for boolean (aka checkboxes)
  config.wrappers :vertical_boolean, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper tag: "div", class: "flex items-center gap-2" do |ba|
      ba.use :input,
             class: "checkbox checkbox-primary", error_class: "checkbox-error", valid_class: "checkbox-success"
      ba.use :label, class: "label cursor-pointer", error_class: "text-error"
    end
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
  end

  # vertical input for radio buttons and check boxes
  config.wrappers :vertical_collection, item_wrapper_class: "flex items-center gap-2",
                                        item_label_class: "label cursor-pointer", tag: "fieldset", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "label",
                           error_class: "text-error" do |ba|
      ba.use :label_text
    end
    b.use :input,
          class: "radio radio-primary", error_class: "radio-error", valid_class: "radio-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical file input
  config.wrappers :vertical_file, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "file-input file-input-bordered w-full", error_class: "file-input-error",
                  valid_class: "file-input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical textarea input
  config.wrappers :vertical_textarea, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "textarea textarea-bordered w-full", error_class: "textarea-error", valid_class: "textarea-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical multi select
  config.wrappers :vertical_multi_select, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.wrapper tag: "div", class: "flex gap-2" do |ba|
      ba.use :input, class: "select select-bordered", error_class: "select-error", valid_class: "select-success"
    end
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical date input
  config.wrappers :vertical_date, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical time input
  config.wrappers :vertical_time, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical date time
  config.wrappers :vertical_datetime, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical date time zone
  config.wrappers :vertical_datetime_local, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "input input-bordered w-full", error_class: "input-error", valid_class: "input-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical select
  config.wrappers :vertical_select, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "select select-bordered w-full", error_class: "select-error", valid_class: "select-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
  end

  # vertical range
  config.wrappers :vertical_range, tag: "div", class: "form-control mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.optional :step
    b.use :label, class: "label", error_class: "text-error"
    b.use :input, class: "range range-primary", error_class: "range-error", valid_class: "range-success"
    b.use :full_error, wrap_with: { tag: "p", class: "text-error text-sm mt-1" }
    b.use :hint, wrap_with: { tag: "p", class: "text-base-content/70 text-sm mt-1" }
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
    textarea: :vertical_textarea,
    time: :vertical_time,
    datetime_local: :vertical_datetime_local
  }
end
