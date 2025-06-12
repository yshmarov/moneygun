import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="click"
export default class extends Controller {
  click(event) {
    const formElements = ['INPUT', 'TEXTAREA', 'SELECT']
    if (formElements.includes(event.target.tagName)) {
      return
    }

    // Prevent default browser behavior for keyboard shortcuts
    if (event?.type === 'keydown') {
      event.preventDefault()
    }

    this.element.click()
  }
}