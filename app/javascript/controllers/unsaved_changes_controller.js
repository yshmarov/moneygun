import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { dirty: { type: Boolean, default: false }, message: String }

  connect() {
    this.submitting = false
  }
  markDirty() {
    this.dirtyValue = true
  }
  beforeUnload(event) {
    if (this.isDirty) event.preventDefault()
  }
  beforeVisit(event) {
    if (this.isDirty && !window.confirm(this.messageValue)) event.preventDefault()
  }
  submitStart() {
    this.submitting = true
  }
  submitEnd(event) {
    this.submitting = false
    if (event.detail.success) this.dirtyValue = false
  }
  get isDirty() {
    return !this.submitting && this.dirtyValue
  }
}
