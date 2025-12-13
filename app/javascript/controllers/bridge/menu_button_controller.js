import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "menu-button"

  connect() {
    super.connect()
    this.send("connect", {}, () => {
      window.dispatchEvent(new CustomEvent("toggle-nav-bar"))
    })
  }
}
