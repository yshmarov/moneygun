import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "review-prompt"

  connect() {
    super.connect()
    this.send("connect")
  }
}
