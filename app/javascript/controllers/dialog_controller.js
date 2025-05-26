import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.open()
    // needed because ESC key does not trigger close event
    this.element.addEventListener("close", this.enableBodyScroll.bind(this))
    // Add ESC key listener to handle cases where input fields have focus
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  disconnect() {
    this.element.removeEventListener("close", this.enableBodyScroll.bind(this))
    document.removeEventListener("keydown", this.handleEscape)
  }

  // Handle ESC key to close modal even when input fields have focus
  handleEscape(event) {
    if (event.key === "Escape" && this.element.open) {
      event.preventDefault()
      this.close()
    }
  }

  // hide modal on successful form submission
  // data-action="turbo:submit-end->turbo-modal#hideOnSubmit"
  hideOnSubmit(e) {
    if (e.detail.success) {
      this.close()
    }
  }

  open() {
    this.element.showModal()
    document.body.classList.add('overflow-hidden')
    
    // Remove focus from auto-focused element (usually close button)
    document.activeElement.blur()
  }

  close() {
    this.element.close()
    const frame = document.getElementById('modal')
    frame.removeAttribute("src")
    frame.innerHTML = ""
  }

  enableBodyScroll() {
    document.body.classList.remove('overflow-hidden')
  }

  clickOutside(event) {
    if (event.target === this.element) {
      this.close()
    }
  }
}
