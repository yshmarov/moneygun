import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    const active = this.element.querySelector("[aria-selected='true']")
    if (active) {
      active.scrollIntoView({ inline: 'center', block: 'nearest', behavior: 'instant' })
    }
  }
}
