import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    // Store the element that had focus before opening the modal
    this.previouslyFocusedElement = document.activeElement
    this.open()
    // needed because ESC key does not trigger close event
    this.boundEnableBodyScroll = this.enableBodyScroll.bind(this)
    this.boundRestoreFocus = this.restoreFocus.bind(this)
    this.element.addEventListener('close', this.boundEnableBodyScroll)
    this.element.addEventListener('close', this.boundRestoreFocus)
  }

  disconnect() {
    this.element.removeEventListener('close', this.boundEnableBodyScroll)
    this.element.removeEventListener('close', this.boundRestoreFocus)
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
  }

  close() {
    this.element.close()
    const frame = document.getElementById('modal')
    frame.removeAttribute('src')
    frame.innerHTML = ''
  }

  restoreFocus() {
    if (this.previouslyFocusedElement && this.previouslyFocusedElement.focus) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }
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
