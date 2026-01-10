import { Controller } from '@hotwired/stimulus'
import { computePosition, flip, shift, offset } from '@floating-ui/dom'

export default class extends Controller {
  static targets = ['button', 'menu']
  static values = {
    hover: { type: Boolean, default: false }, // Toggle menu on hover
    placement: { type: String, default: 'bottom-start' } // Preferred placement(s)
  }

  // Constants
  static CLOSE_DELAY = 100
  static HOVER_DELAY = 80
  static OFFSET = 4
  static SHIFT_PADDING = 8
  static MUTATION_DELAY = 10

  connect() {
    this.closeTimeout = null
    this.#registerHandlers()
    this.#setupObservers()
    this.#setupHoverBehaviour()
  }

  disconnect() {
    // Clear any pending timeouts
    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout)
      this.closeTimeout = null
    }
    if (this.hoverTimeout) {
      clearTimeout(this.hoverTimeout)
      this.hoverTimeout = null
    }

    this.#teardownHandlers()
    this.#teardownObservers()
  }

  get isOpen() {
    return this.menuTarget.hasAttribute('data-open')
  }

  async show() {
    if (this.isOpen) return

    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout)
      this.closeTimeout = null
    }

    this.#closeOtherDropdowns()

    this.menuTarget.setAttribute('data-open', 'true')
    this.menuTarget.style.opacity = '1'
    this.menuTarget.style.pointerEvents = 'auto'
    this.#updateExpanded()

    try {
      await this.#updatePosition()
    } catch (error) {
      // Fallback: position relative to button if FloatingUI fails
      const buttonRect = this.buttonTarget.getBoundingClientRect()
      Object.assign(this.menuTarget.style, {
        position: 'fixed',
        left: `${buttonRect.left}px`,
        top: `${buttonRect.bottom + this.constructor.OFFSET}px`,
        margin: 0
      })
    }

    requestAnimationFrame(() => {
      const autofocusElement = this.menuTarget.querySelector('[autofocus="true"], [autofocus]')

      if (autofocusElement) {
        setTimeout(() => {
          autofocusElement.focus()

          if (autofocusElement.tagName === 'INPUT' || autofocusElement.tagName === 'TEXTAREA') {
            const length = autofocusElement.value.length
            autofocusElement.setSelectionRange(length, length)
          }
        }, 0)
      } else {
        const firstMenuItem = this.menuTarget.querySelector('[role="menuitem"]')
        if (firstMenuItem) {
          firstMenuItem.focus()
        }
      }
    })
  }

  close() {
    if (!this.isOpen) return

    if (this.closeTimeout) {
      clearTimeout(this.closeTimeout)
    }

    const menuController = this.application.getControllerForElementAndIdentifier(this.menuTarget, 'menu')
    if (menuController) menuController.reset()

    this.closeTimeout = setTimeout(() => {
      this.menuTarget.removeAttribute('data-open')
      this.menuTarget.style.opacity = '0'
      this.menuTarget.style.pointerEvents = 'none'
      this.#updateExpanded()
      this.closeTimeout = null
    }, this.constructor.CLOSE_DELAY)
  }

  toggle() {
    this.isOpen ? this.close() : this.show()
  }

  closeOnClickOutside({ target }) {
    if (!this.element.contains(target)) {
      this.close()
    }
  }

  preventClose(event) {
    event.stopPropagation()
  }

  reset() {
    const menuController = this.application.getControllerForElementAndIdentifier(this.menuTarget, 'menu')
    menuController?.reset()

    const resetEvent = new CustomEvent('dropdown-reset', {
      bubbles: true,
      detail: { controller: this }
    })
    this.element.dispatchEvent(resetEvent)
  }

  async #updatePosition() {
    const placements = this.placementValue.split(/[\s,]+/).filter(Boolean)
    const primaryPlacement = placements[0] || 'bottom-start'
    const fallbackPlacements = placements.slice(1)

    const middleware = [
      offset(this.constructor.OFFSET),
      flip({
        fallbackPlacements: fallbackPlacements.length > 0 ? fallbackPlacements : ['top-start', 'bottom-start']
      }),
      shift({ padding: this.constructor.SHIFT_PADDING })
    ]

    const { x, y } = await computePosition(this.buttonTarget, this.menuTarget, {
      placement: primaryPlacement,
      strategy: 'fixed', // Use fixed positioning for proper viewport-relative positioning
      middleware
    })

    Object.assign(this.menuTarget.style, {
      position: 'fixed', // Ensure fixed positioning
      left: `${x}px`,
      top: `${y}px`,
      margin: 0 // Remove any default margins
    })
  }

  #registerHandlers() {
    this.handleMenuItemClick = () => {
      this.close()
    }
    this.menuTarget.addEventListener('menu-item-clicked', this.handleMenuItemClick)

    this.handleDocumentKeydown = event => {
      if (event.key === 'Escape' && this.isOpen) this.close()
    }
    document.addEventListener('keydown', this.handleDocumentKeydown)

    this.handleButtonKeydown = event => {
      if (!this.isOpen) return

      const menuController = this.application.getControllerForElementAndIdentifier(this.menuTarget, 'menu')

      if (event.key === 'ArrowDown') {
        event.preventDefault()
        menuController.selectFirst()
      } else if (event.key === 'ArrowUp') {
        event.preventDefault()
        menuController.selectLast()
      }
    }
    this.buttonTarget.addEventListener('keydown', this.handleButtonKeydown)

    this.handleCloseHoverDropdowns = () => {
      if (this.hoverValue) return

      const openHoverDropdowns = this.application.controllers.filter(
        controller => controller.identifier === 'dropdown-popover' && controller !== this && controller.isOpen && controller.hoverValue
      )

      openHoverDropdowns.forEach(controller => controller.close())
    }
    this.buttonTarget.addEventListener('mouseenter', this.handleCloseHoverDropdowns)
  }

  #teardownHandlers() {
    this.menuTarget.removeEventListener('menu-item-clicked', this.handleMenuItemClick)
    document.removeEventListener('keydown', this.handleDocumentKeydown)
    this.buttonTarget.removeEventListener('keydown', this.handleButtonKeydown)
    this.buttonTarget.removeEventListener('mouseenter', this.handleCloseHoverDropdowns)

    if (this.hoverValue) {
      this.buttonTarget.removeEventListener('mouseenter', this.handleButtonMouseEnter)
      this.buttonTarget.removeEventListener('mouseleave', this.handleButtonMouseLeave)
      this.menuTarget.removeEventListener('mouseenter', this.handleMenuMouseEnter)
      this.menuTarget.removeEventListener('mouseleave', this.handleMenuMouseLeave)
    }
  }

  #setupObservers() {
    this.scrollHandler = () => {
      if (this.isOpen) this.#updatePosition()
    }
    window.addEventListener('scroll', this.scrollHandler, true)

    this.resizeObserver = new ResizeObserver(() => {
      if (this.isOpen) this.#updatePosition()
    })
    this.resizeObserver.observe(document.body)
    this.resizeObserver.observe(this.menuTarget)

    this.mutationObserver = new MutationObserver(() => {
      if (this.isOpen) {
        setTimeout(() => this.#updatePosition(), this.constructor.MUTATION_DELAY)
      }
    })
    this.mutationObserver.observe(this.menuTarget, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['style', 'class']
    })
  }

  #teardownObservers() {
    window.removeEventListener('scroll', this.scrollHandler, true)
    if (this.resizeObserver) this.resizeObserver.disconnect()
    if (this.mutationObserver) this.mutationObserver.disconnect()
  }

  #setupHoverBehaviour() {
    if (!this.hoverValue) return

    this.hoverTimeout = null

    this.handleButtonMouseEnter = () => {
      clearTimeout(this.hoverTimeout)
      this.show()
    }
    this.buttonTarget.addEventListener('mouseenter', this.handleButtonMouseEnter)

    this.handleButtonMouseLeave = () => {
      this.hoverTimeout = setTimeout(() => this.close(), this.constructor.HOVER_DELAY)
    }
    this.buttonTarget.addEventListener('mouseleave', this.handleButtonMouseLeave)

    this.handleMenuMouseEnter = () => {
      clearTimeout(this.hoverTimeout)
    }
    this.menuTarget.addEventListener('mouseenter', this.handleMenuMouseEnter)

    this.handleMenuMouseLeave = () => {
      this.hoverTimeout = setTimeout(() => this.close(), this.constructor.HOVER_DELAY)
    }
    this.menuTarget.addEventListener('mouseleave', this.handleMenuMouseLeave)
  }

  #closeOtherDropdowns() {
    const openDropdowns = this.application.controllers.filter(
      controller => controller.identifier === 'dropdown-popover' && controller !== this && controller.isOpen
    )

    openDropdowns.forEach(controller => {
      if (!this.element.contains(controller.element) && !controller.element.contains(this.element)) {
        controller.close()
      }
    })
  }

  #updateExpanded() {
    this.buttonTarget.ariaExpanded = this.isOpen
  }
}
