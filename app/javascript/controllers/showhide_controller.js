import { Controller } from "@hotwired/stimulus"

// HMTL example
// <button data-controller="showhide" data-action="showhide#toggle" data-showhide-target-id-value="element-id">Show/Hide</button>
// <div id="element-id" class="hidden">Content to show/hide</div>

// Connects to data-controller="showhide"
export default class extends Controller {
  static values = { targetId: String }

  toggle() {
    const element = document.getElementById(this.targetIdValue)
    if (element) {
      // if element has class "hidden", remove it
      if (element.classList.contains("hidden")) {
        element.classList.remove("hidden")
        // add flex
        element.classList.add("flex")
      } else {
        // otherwise, add class "hidden"
        element.classList.add("hidden")
        // remove flex
        element.classList.remove("flex")
      }
    }
  }
}
