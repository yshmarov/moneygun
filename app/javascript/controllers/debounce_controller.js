import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  submit(event) {
    event.preventDefault()
    event.stopPropagation()
    setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
