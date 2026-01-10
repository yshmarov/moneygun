import { Controller } from '@hotwired/stimulus'

// <div data-controller="element-remove" data-action="click->element-remove#click">Click me to remove me</div>
// Connects to data-controller="element-remove"
export default class extends Controller {
  click() {
    this.element.remove()
  }
}
