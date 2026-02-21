import { Controller } from '@hotwired/stimulus'
import { computePosition, flip, shift, offset, autoUpdate } from '@floating-ui/dom'

export default class extends Controller {
  static values = { content: String }

  connect() {
    this.tooltip = null
    this.cleanup = null
  }

  disconnect() {
    this.hide()
  }

  show() {
    if (this.tooltip) return

    this.tooltip = document.createElement('div')
    this.tooltip.className = 'floating-tooltip'
    this.tooltip.textContent = this.contentValue
    document.body.appendChild(this.tooltip)

    this.cleanup = autoUpdate(this.element, this.tooltip, () => {
      computePosition(this.element, this.tooltip, {
        placement: 'top',
        middleware: [offset(8), flip({ fallbackPlacements: ['bottom', 'left', 'right'] }), shift({ padding: 8 })]
      }).then(({ x, y }) => {
        Object.assign(this.tooltip.style, {
          left: `${x}px`,
          top: `${y}px`
        })
      })
    })
  }

  hide() {
    if (this.cleanup) {
      this.cleanup()
      this.cleanup = null
    }
    if (this.tooltip) {
      this.tooltip.remove()
      this.tooltip = null
    }
  }
}
