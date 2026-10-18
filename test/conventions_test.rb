# frozen_string_literal: true

require "test_helper"

class ConventionsTest < ActiveSupport::TestCase
  test "every SVG declares the SVG namespace" do
    missing = Rails.root.glob("{app/assets/images,public}/**/*.svg").reject do |svg|
      svg.read.include?('xmlns="http://www.w3.org/2000/svg"')
    end

    assert_empty(missing.map { |svg| svg.relative_path_from(Rails.root).to_s })
  end

  test "every controller has a controller test" do
    controllers = Rails.root.join("app/controllers")
    untested = controllers.glob("**/*_controller.rb").filter_map do |controller|
      path = controller.relative_path_from(controllers).to_s
      next if path.start_with?("avo/") || path.end_with?("application_controller.rb", "base_controller.rb")

      path unless Rails.root.join("test/controllers", path.sub(/\.rb\z/, "_test.rb")).exist?
    end

    assert_empty untested, "Add test/controllers/<path>_test.rb for each controller."
  end

  test "enums are string-backed" do
    Rails.application.eager_load!
    integer_backed = ApplicationRecord.descendants.flat_map do |model|
      model.defined_enums.filter_map { |name, mapping| "#{model.name}.#{name}" unless mapping.values.all?(String) }
    end

    assert_empty integer_backed
  end
end
