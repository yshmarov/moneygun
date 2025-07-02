import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['row']

  connect() {
    this.handleClickBound = this.handleClick.bind(this)
    this.rowTargets.forEach((row) => {
      row.addEventListener('click', this.handleClickBound)
    })
  }

  handleClick(event) {
    // Check if the click event originated from any interactive element
    if (this.isInteractiveElement(event.target)) {
      return // Do nothing if an interactive element was clicked
    }
    const url = event.currentTarget.dataset.url
    if (url) {
      window.location.href = url
    }
  }

  isInteractiveElement(element) {
    // Check for common interactive elements, those with tabindex, and specific elements like dialog and details
    return element.closest(
      'a, button, input, select, textarea, [tabindex], [role="button"], [role="link"], dialog, details, summary'
    )
  }

  disconnect() {
    this.rowTargets.forEach((row) => {
      row.removeEventListener('click', this.handleClickBound)
    })
  }
}
