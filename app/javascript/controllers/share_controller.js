import { Controller } from '@hotwired/stimulus'

// Uses the Web Share API when available, falls back to copying the URL to clipboard.
// Usage:
//   <button data-controller="share"
//           data-share-title-value="Page title"
//           data-share-url-value="https://example.com/page">
//     Share
//   </button>
export default class extends Controller {
  static values = {
    title: String,
    url: { type: String, default: '' },
    successText: { type: String, default: '\u2713' }
  }

  disconnect() {
    if (this._timeout) clearTimeout(this._timeout)
  }

  async share() {
    const url = this.urlValue || window.location.href
    const title = this.titleValue

    if (navigator.share) {
      try {
        await navigator.share({ title, url })
      } catch {
        // User cancelled or share failed — ignore
      }
    } else {
      await navigator.clipboard.writeText(url)
      const label = this.element.querySelector('[data-share-label]')
      if (label) {
        const original = label.innerHTML
        label.textContent = this.successTextValue
        this._timeout = setTimeout(() => {
          label.innerHTML = original
        }, 2000)
      }
    }
  }
}
