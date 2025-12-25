import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "notification-badge"

  // Unread notification counts
  static values = {
    total: Number,
    account: Number
  }

  totalValueChanged() {
    this.send("update", { app: this.totalValue, tab: this.accountValue })
  }
}
