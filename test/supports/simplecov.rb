# frozen_string_literal: true

require "simplecov"

Rake.respond_to?(:application) &&
  Rake.application.respond_to?(:top_level_tasks) &&
  Rake.application.top_level_tasks.any? { |e| e.eql?("test:prepare") }

FileUtils.rm_f("coverage/.resultset.json")

if ENV["COVERAGE"] != "false"
  SimpleCov.minimum_coverage 80
end

SimpleCov.start(:rails) do
  # Ignore files without functional code
  add_filter do |source_file|
    source = source_file.src
    ignored = source.reduce(0) do |ignored, line|
      case line.strip
      when /^$/, /^#/, /^class/, /^module/, /^end/
        ignored += 1
      end
      ignored
    end
    (source.count - ignored) <= 0
  end

  enable_coverage :branch

  add_group "Policies", "app/policies"

  at_exit do
    SimpleCov.formatter = SimpleCov::Formatter::SimpleFormatter
    SimpleCov.result.format!
  end
end
