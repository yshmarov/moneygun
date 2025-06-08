import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: { type: Number, default: 0 },
    end: Number,
    duration: { type: Number, default: 300 },
    type: String,
    currency: { type: String, default: "USD" }
  }

  connect() {
    this.animate()
  }

  animate() {
    const start = this.startValue
    const end = this.endValue
    const duration = this.durationValue
    const increment = (end - start) / (duration / 16) // ~60fps

    let current = start
    const timer = setInterval(() => {
      current += increment
      if (current >= end) {
        current = end
        clearInterval(timer)
      }
      this.updateDisplay(current)
    }, 16)
  }

  updateDisplay(value) {
    if (this.typeValue === "money") {
      this.element.textContent = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: this.currencyValue
      }).format(value)
    } else {
      this.element.textContent = new Intl.NumberFormat('en-US').format(Math.round(value))
    }
  }
} 