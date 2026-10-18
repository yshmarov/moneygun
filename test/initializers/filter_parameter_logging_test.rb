# frozen_string_literal: true

require "test_helper"

class FilterParameterLoggingTest < ActiveSupport::TestCase
  test "filters one-time codes and SAML assertions" do
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)

    filtered = filter.filter("code" => "123456", "SAMLResponse" => "assertion", "country_code" => "PL")

    assert_equal({ "code" => "[FILTERED]", "SAMLResponse" => "[FILTERED]", "country_code" => "PL" }, filtered)
  end
end
