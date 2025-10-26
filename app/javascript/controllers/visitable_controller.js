import { Controller } from '@hotwired/stimulus'

// clickable area that visits a URL when clicked
// <div data-controller="visitable" data-url="/some/url" data-action="click->visitable#visit">Click me to visit</div>
export default class extends Controller {
  visit(event) {
    // Do nothing if an interactive element was clicked
    if (this.isInteractiveElement(event.target)) {
      return
    }

    const url = this.element.dataset.url
    if (url) {
      const turboFrame = event.currentTarget.dataset.turboFrame
      const turboAction = event.currentTarget.dataset.turboAction

      const visitOptions = {}
      if (turboFrame) {
        visitOptions.frame = turboFrame
      }
      if (turboAction) {
        visitOptions.action = turboAction
      }

      if (Object.keys(visitOptions).length > 0) {
        Turbo.visit(url, visitOptions)
      } else {
        Turbo.visit(url)
      }
    }
  }

  isInteractiveElement(element) {
    // Check for common interactive elements, those with tabindex, and specific elements like dialog and details
    return element.closest(
      'a, button, input, select, textarea dialog, details, summary, [role="menu"], [role="button"]'
    )
  }
}
