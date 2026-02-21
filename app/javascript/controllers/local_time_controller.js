import { Controller } from '@hotwired/stimulus'

// Replaces the local-time npm package.
// Reads the UTC datetime attribute and formats it in the user's local timezone.
//
// Usage:
//   <time datetime="2026-02-17T10:00:00Z"
//         data-controller="local-time"
//         data-local-time-format-value="short">
//     Feb 17, 2026
//   </time>
export default class extends Controller {
  static values = { format: { type: String, default: 'short' } }

  connect() {
    this.update()
  }

  update() {
    const date = new Date(this.element.dateTime)
    if (isNaN(date)) return

    this.element.textContent = this.formatDate(date)
  }

  formatDate(date) {
    if (this.formatValue === 'long') {
      return date.toLocaleString(undefined, {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
        hour: 'numeric',
        minute: '2-digit'
      })
    }

    return date.toLocaleDateString(undefined, {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    })
  }
}
