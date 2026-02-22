import { Controller } from '@hotwired/stimulus'

const GSI_SRC = 'https://accounts.google.com/gsi/client'

export default class extends Controller {
  static values = {
    clientId: String,
    loginUri: String
  }

  connect() {
    if (document.querySelector(`script[src="${GSI_SRC}"]`)) return

    this.script = document.createElement('script')
    this.script.src = GSI_SRC
    this.script.async = true
    document.head.appendChild(this.script)
  }

  disconnect() {
    this.script?.remove()
  }
}
