import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['source', 'button', 'status']
  static values = { successContent: String, successMessage: String, failureContent: String, resetDelay: { type: Number, default: 2000 } }

  connect() {
    this.defaultButtonContent = this.hasButtonTarget ? this.buttonTarget.innerHTML : null
    this.statusElement = this.hasStatusTarget ? this.statusTarget : this.#buildStatusElement()
  }

  disconnect() {
    clearTimeout(this.resetTimeout)
    cancelAnimationFrame(this.announcementFrame)
    if (!this.hasStatusTarget) this.statusElement.remove()
  }

  async copy() {
    try {
      await navigator.clipboard.writeText(this.#sourceText())
      this.#announce(this.successMessageValue || this.successContentValue)
      if (this.hasButtonTarget && this.successContentValue) {
        this.buttonTarget.innerHTML = this.successContentValue
        clearTimeout(this.resetTimeout)
        this.resetTimeout = setTimeout(() => {
          this.buttonTarget.innerHTML = this.defaultButtonContent
        }, this.resetDelayValue)
      }
    } catch (_error) {
      this.#announce(this.failureContentValue)
    }
  }

  #sourceText() {
    if (this.sourceTarget instanceof HTMLInputElement || this.sourceTarget instanceof HTMLTextAreaElement) {
      return this.sourceTarget.value
    }

    return this.sourceTarget.textContent.trim()
  }

  #announce(message) {
    cancelAnimationFrame(this.announcementFrame)
    this.statusElement.textContent = ''
    this.announcementFrame = requestAnimationFrame(() => {
      if (this.statusElement.isConnected) this.statusElement.textContent = message
    })
  }

  #buildStatusElement() {
    const element = document.createElement('p')
    element.className = 'sr-only'
    element.setAttribute('aria-live', 'polite')
    this.element.appendChild(element)
    return element
  }
}
