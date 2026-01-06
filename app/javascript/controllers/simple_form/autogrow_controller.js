import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    maxHeight: { type: Number, default: 15 }
  }

  connect() {
    this.resize()
  }

  resize() {
    const textarea = this.element
    textarea.style.height = 'auto'
    textarea.style.overflowY = 'hidden'

    // while textarea scrollHeight > textarea offsetHeight & textarea offsetHeight < this.maxHeightValue (5) rows * height of 1 row
    while (
      textarea.scrollHeight > textarea.offsetHeight &&
      textarea.offsetHeight < this.maxHeightValue * parseFloat(getComputedStyle(textarea).lineHeight)
    ) {
      // increase height of textarea by one row
      textarea.style.height = `${textarea.offsetHeight + parseFloat(getComputedStyle(textarea).lineHeight)}px`
    }
    // if textarea already has > maxHeight rows, activate scroll
    if (textarea.offsetHeight >= this.maxHeightValue * parseFloat(getComputedStyle(textarea).lineHeight)) {
      textarea.style.overflowY = 'auto'
    }
  }
}
