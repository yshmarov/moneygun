# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "turbo_power" # @0.7.1
pin "@stimulus-components/clipboard", to: "@stimulus-components--clipboard.js" # @5.0.0
pin "autonumeric", to: "https://ga.jspm.io/npm:autonumeric@4.6.0/dist/autoNumeric.min.js"
pin "@stimulus-components/animated-number", to: "@stimulus-components--animated-number.js" # @5.0.0
pin "@stimulus-components/auto-submit", to: "@stimulus-components--auto-submit.js" # @6.0.0
pin "local-time" # @3.0.3
