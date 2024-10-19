import { Controller } from "@hotwired/stimulus"
// <button data-controller="toggle-aria" data-action="click->toggle-aria#toggle" data-toggle-aria-target-id-value="element-id">Toggle Aria</button>
// <div id="element-id" aria-hidden="true">Content to show/hide</div>
export default class extends Controller {
  static values = { targetId: String }

  toggle() {
    const element = document.getElementById(this.targetIdValue)
    if (element) {
      const isHidden = element.getAttribute("aria-hidden") === "true"
      element.setAttribute("aria-hidden", isHidden ? "false" : "true")
    }
  }
}