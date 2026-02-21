# frozen_string_literal: true

# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/helpers", under: "helpers"
pin "turbo_power" # @0.7.1
pin "@stimulus-components/clipboard", to: "@stimulus-components--clipboard.js" # @5.0.0
pin "autonumeric", to: "https://ga.jspm.io/npm:autonumeric@4.6.0/dist/autoNumeric.min.js", preload: false
pin "@stimulus-components/animated-number", to: "@stimulus-components--animated-number.js", preload: false # @5.0.0
pin "@stimulus-components/auto-submit", to: "@stimulus-components--auto-submit.js" # @6.0.0
pin "@floating-ui/utils", to: "https://ga.jspm.io/npm:@floating-ui/utils@0.2.8/dist/floating-ui.utils.mjs"
pin "@floating-ui/core", to: "https://ga.jspm.io/npm:@floating-ui/core@1.6.8/dist/floating-ui.core.mjs"
pin "@floating-ui/utils/dom", to: "https://ga.jspm.io/npm:@floating-ui/utils@0.2.8/dist/floating-ui.utils.dom.mjs"
pin "@floating-ui/dom", to: "https://ga.jspm.io/npm:@floating-ui/dom@1.6.12/dist/floating-ui.dom.mjs"
pin "lexxy"
pin "turbo_confirm"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "@rails/activestorage", to: "activestorage.esm.js"
pin "dropzone", to: "https://esm.sh/dropzone@6.0.0-beta.2?bundle", preload: false
