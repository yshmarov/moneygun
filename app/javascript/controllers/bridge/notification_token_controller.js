import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "notification-token"

  connect() {
    super.connect()
    this.send("connect")
  }
}
