# frozen_string_literal: true

require "test_helper"

class HotwireNativeHelperTest < ActionView::TestCase
  setup do
    def root_url
      "http://test.host/"
    end
  end

  test "link_to removes target for internal links in turbo native app" do
    def turbo_native_app?
      true
    end

    result = link_to("Home", "/foo/bar", target: "_blank", rel: "noopener")
    assert_no_match(/target="_blank"/, result)
  end

  test "link_to keeps target for external links in turbo native app" do
    def turbo_native_app?
      true
    end

    result = link_to("External", "http://external.com", target: "_blank", rel: "noopener")
    assert_match(/target="_blank"/, result)
  end

  test "link_to keeps target for internal links when not in turbo native app" do
    def turbo_native_app?
      false
    end

    result = link_to("Home", root_url, target: "_blank", rel: "noopener")
    assert_match(/target="_blank"/, result)
  end

  test "link_to keeps target for external links when not in turbo native app" do
    def turbo_native_app?
      false
    end

    result = link_to("External", "http://external.com", target: "_blank", rel: "noopener")
    assert_match(/target="_blank"/, result)
  end

  test "internal_url? returns true for internal links" do
    assert internal_url?("http://test.host/some_path")
  end

  test "internal_url? returns false for external links" do
    assert_not internal_url?("http://external.com")
  end
end
