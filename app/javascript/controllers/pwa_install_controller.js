import { Controller } from '@hotwired/stimulus'

// Intercepts the browser's native install prompt and defers it so we can
// trigger it from our own UI (e.g. an "Install app" button).
//
// Usage:
//   <div data-controller="pwa-install" class="hidden" data-pwa-install-installable-class="!flex">
//     <button data-action="pwa-install#promptInstall">Install app</button>
//   </div>
export default class extends Controller {
  static classes = ['installable']

  connect() {
    if (window.matchMedia('(display-mode: standalone)').matches) return

    this.handleBeforeInstallPrompt = this.#beforeInstallPrompt.bind(this)
    this.handleAppInstalled = this.#appInstalled.bind(this)

    window.addEventListener('beforeinstallprompt', this.handleBeforeInstallPrompt)
    window.addEventListener('appinstalled', this.handleAppInstalled)
  }

  disconnect() {
    window.removeEventListener('beforeinstallprompt', this.handleBeforeInstallPrompt)
    window.removeEventListener('appinstalled', this.handleAppInstalled)
  }

  async promptInstall() {
    if (!this.deferredPrompt) return

    this.deferredPrompt.prompt()
    await this.deferredPrompt.userChoice
    this.deferredPrompt = null
    this.element.classList.remove(...this.installableClasses)
  }

  // private

  #beforeInstallPrompt(event) {
    event.preventDefault()
    this.deferredPrompt = event
    this.element.classList.add(...this.installableClasses)
  }

  #appInstalled() {
    this.deferredPrompt = null
    this.element.classList.remove(...this.installableClasses)
  }
}
