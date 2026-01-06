import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { closeOnClickOutside: { type: Boolean, default: true } }

  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)

    document.addEventListener('click', this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      // Only close if closeOnClickOutside is true
      if (this.closeOnClickOutsideValue) {
        this.close()
      }
    }
  }

  close() {
    this.element.removeAttribute('open')
  }
}
