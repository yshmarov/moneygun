import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'sign-out'

  static values = {
    path: String
  }

  signOut(event) {
    event.preventDefault()
    event.stopImmediatePropagation()

    const path = this.pathValue
    this.send('signOut', { path }, () => {})
  }
}
