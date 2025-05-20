import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.open()
    // needed because ESC key does not trigger close event
    this.element.addEventListener("close", this.enableBodyScroll.bind(this))
  }

  disconnect() {
    this.element.removeEventListener("close", this.enableBodyScroll.bind(this))
  }

  // hide modal on successful form submission
  // data-action="turbo:submit-end->turbo-modal#submitEnd"
  submitEnd(e) {
    if (e.detail.success) {
      this.close()
    }
  }

  open() {
    this.element.showModal()
    document.body.classList.add('overflow-hidden')
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
