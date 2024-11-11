import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "overflow-menu"

  connect() {
    super.connect()
    this.notifyBridgeOfConnect()
  }

  notifyBridgeOfConnect() {
    const label = this.bridgeElement.title

    this.send("connect", { label }, () => {
      this.bridgeElement.click()
    })
  }
}