import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  connect() {
    this.dialog = document.createElement('dialog')
    this.dialog.classList.add('lightbox-dialog')
    this.dialog.innerHTML = `
      <div class="relative">
        <button type="button" class="lightbox-close absolute -top-10 -right-2 bg-transparent border-0 text-white text-3xl leading-none cursor-pointer px-2 py-1 opacity-70 hover:opacity-100 transition-opacity" aria-label="Close">&times;</button>
        <img class="lightbox-img max-w-[85vw] max-h-[85vh] object-contain rounded-lg block" />
      </div>
    `
    this.dialog.addEventListener('click', e => {
      // Close when clicking the backdrop (dialog itself) or the close button
      if (e.target === this.dialog || e.target.closest('.lightbox-close')) {
        this.dialog.close()
      }
    })
    document.body.appendChild(this.dialog)
  }

  disconnect() {
    this.dialog?.remove()
  }

  open(event) {
    const img = event.currentTarget
    if (img.tagName !== 'IMG') return

    this.dialog.querySelector('.lightbox-img').src = img.src
    this.dialog.showModal()
  }
}
