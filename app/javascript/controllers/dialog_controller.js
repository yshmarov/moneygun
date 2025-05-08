import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "loadingTemplate", "content"]

  connect() {
    this.boundBeforeCache = this.beforeCache.bind(this)
    document.addEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.boundBeforeCache)
  }

  open() {
    this.contentTarget.innerHTML = this.loadingTemplateTarget.innerHTML
    this.dialogTarget.showModal()
  }

  close() {
    this.dialogTarget.close()
  }

  backdropClick(event) {
    if (event.target.nodeName == "DIALOG") {
      this.close()
    }
  }

  beforeCache() {
    if (this.dialogTarget.open) {
      this.dialogTarget.close()
    }
  }
}
