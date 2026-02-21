import { Controller } from '@hotwired/stimulus'

// Sets the PWA app badge count using the Badge API.
// Reads the count from a Stimulus value so the server can set it on each page load.
//
// Usage:
//   <div data-controller="badge" data-badge-count-value="3" hidden></div>
export default class extends Controller {
  static values = { count: { type: Number, default: 0 } }

  countValueChanged() {
    this.#updateBadge()
  }

  // private

  #updateBadge() {
    if (!navigator.setAppBadge) return

    if (this.countValue > 0) {
      navigator.setAppBadge(this.countValue)
    } else {
      navigator.clearAppBadge()
    }
  }
}
