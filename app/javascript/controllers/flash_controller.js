import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { autoDismiss: { type: Number, default: 0 } }

  connect() {
    if (this.autoDismissValue > 0) this.timeout = setTimeout(() => this.element.remove(), this.autoDismissValue)
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  dismiss() {
    this.element.remove()
  }
}
