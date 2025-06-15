// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Turbo } from '@hotwired/turbo'
import "controllers"
import TurboPower from 'turbo_power'
TurboPower.initialize(Turbo.StreamActions)

// https://github.com/hotwired/turbo-rails/pull/367#issuecomment-2908152307
document.addEventListener('turbo:frame-missing', (event) => {
  if (event.target.id === 'modal') {
    event.preventDefault()

    event.detail.visit(event.detail.response.url, { action: 'replace' })
  }
})