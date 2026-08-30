# frozen_string_literal: true

require "test_helper"
require "axe-capybara"
require "axe/dsl"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]

  Capybara.default_max_wait_time = 5

  def sign_in(user)
    session_record = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    visit root_path
    page.driver.browser.manage.add_cookie(name: "session_token", value: session_record.signed_id, path: "/")
  end

  def assert_axe_clean(**options)
    assert_no_selector "html[aria-busy='true']"

    matcher = Axe::Matchers.send(:be_axe_clean)
    matcher = matcher.with_options(options) if options.present?
    Axe::DSL.send(:expect, page).to(matcher)
  rescue RuntimeError => e
    flunk e.message
  end
end
