import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.handleClickOutside = this.handleClickOutside.bind(this)
    
    document.addEventListener('click', this.handleClickOutside)
  }

  disconnect() {
    document.removeEventListener('click', this.handleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  close() {
    this.element.removeAttribute('open')
  }
} 