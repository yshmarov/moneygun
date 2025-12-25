import { BridgeComponent } from '@hotwired/hotwire-native-bridge'

export default class extends BridgeComponent {
  static component = 'reset-app'

  connect() {
    // Send message to native app when page loads
    this.send('resetApp', {}, () => {})
  }
}
