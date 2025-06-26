import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form"
export default class extends Controller {
  submit() {
    setTimeout(() => {
      this.element.requestSubmit();
    }, 200);
  }
}
