// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from '@hotwired/turbo'
import 'controllers'
import TurboPower from 'turbo_power'
TurboPower.initialize(Turbo.StreamActions)

import 'lexxy'
import '@rails/actiontext'
import 'turbo_confirm'

// Prevent Lexxy editor toolbar buttons from submitting parent forms.
// Lexxy uses <form method="dialog"> for its link popup, but nested forms are invalid
// HTML — the browser ignores the inner form, so the submit button falls through to the
// outer form. This is safe globally: editor toolbar buttons should never submit forms.
document.addEventListener(
  'submit',
  event => {
    if (event.submitter?.closest('lexxy-editor')) {
      event.preventDefault()
    }
  },
  true
)

if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker', { scope: '/' })
}

// In standalone PWA mode the title bar already shows the app name,
// so strip the trailing " - AppName" suffix to avoid duplication.
if (window.matchMedia('(display-mode: standalone)').matches) {
  const strip = () => {
    const sep = document.title.lastIndexOf(' - ')
    if (sep > 0) document.title = document.title.substring(0, sep)
  }
  strip()
  document.addEventListener('turbo:render', strip)
}
