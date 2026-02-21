import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['messages']

  connect() {
    this.scrollToBottom()
    this._forceScroll = false
    this.observer = new MutationObserver(() => {
      if (this._forceScroll || this.isNearBottom()) {
        this.scrollToBottom(true)
        this._forceScroll = false
      }
    })
    if (this.hasMessagesTarget) {
      this.observer.observe(this.messagesTarget, { childList: true, subtree: true })
    }
  }

  disconnect() {
    if (this.observer) this.observer.disconnect()
  }

  isNearBottom() {
    if (!this.hasMessagesTarget) return true
    return this.messagesTarget.scrollHeight - this.messagesTarget.scrollTop - this.messagesTarget.clientHeight < 100
  }

  forceNextScroll() {
    this._forceScroll = true
  }

  scrollToBottom(smooth = false) {
    if (!this.hasMessagesTarget) return
    if (smooth) {
      this.messagesTarget.scrollTo({ top: this.messagesTarget.scrollHeight, behavior: 'smooth' })
    } else {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
    }
  }
}
