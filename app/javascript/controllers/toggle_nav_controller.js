import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.boundClick = this.click.bind(this)
    window.addEventListener('toggle-nav-bar', this.boundClick)
  }

  disconnect() {
    window.removeEventListener('toggle-nav-bar', this.boundClick)
  }

  click() {
    this.element.click()
  }
}
