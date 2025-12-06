import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['display']
  static values = {
    inputSelector: String,
    limit: Number
  }

  connect() {
    // Find the input within the same form-control wrapper
    const formControl = this.element.closest('.form-control')
    if (!formControl) return

    const input = formControl.querySelector(
      this.inputSelectorValue || 'input, textarea'
    )
    if (!input) return

    this.input = input
    this.updateCount()
    this.input.addEventListener('input', () => this.updateCount())
    this.input.addEventListener('change', () => this.updateCount())
  }

  updateCount() {
    if (!this.input) return

    const count = this.input.value.length
    const display = this.displayTarget

    if (this.hasLimitValue) {
      display.textContent = `${count}/${this.limitValue}`
      // Add error styling if over limit
      const isOverLimit = count > this.limitValue
      display.classList.toggle('text-error', isOverLimit)
      display.classList.toggle('text-base-content/70', !isOverLimit)
    } else {
      display.textContent = count.toString()
    }
  }
}
