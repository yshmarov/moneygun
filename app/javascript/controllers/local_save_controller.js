import { Controller } from '@hotwired/stimulus'
import { debounce, nextFrame } from 'helpers/timing_helpers'

export default class extends Controller {
  static targets = ['input']
  static values = { key: String, fresh: { type: Boolean, default: false } }

  initialize() {
    this.save = debounce(this.save.bind(this), 300)
  }

  connect() {
    if (this.freshValue) {
      this.#clear()
      this.disabled = true
      return
    }
    this.restoreContent()
  }

  submit({ detail: { success } }) {
    if (success) {
      this.#clear()
    }
  }

  save() {
    if (this.disabled) return

    const content = this.inputTarget.value
    if (content) {
      localStorage.setItem(this.keyValue, content)
    } else {
      this.#clear()
    }
  }

  async restoreContent() {
    if (this.disabled) return

    await nextFrame()
    let savedContent = localStorage.getItem(this.keyValue)

    if (savedContent) {
      this.inputTarget.value = savedContent
      this.#triggerChangeEvent(savedContent)
    }
  }

  // Private

  #clear() {
    localStorage.removeItem(this.keyValue)
  }

  #triggerChangeEvent(newValue) {
    if (this.inputTarget.tagName === 'LEXXY-EDITOR') {
      this.inputTarget.dispatchEvent(
        new CustomEvent('lexxy:change', {
          bubbles: true,
          detail: {
            previousContent: '',
            newContent: newValue
          }
        })
      )
    }
  }
}
