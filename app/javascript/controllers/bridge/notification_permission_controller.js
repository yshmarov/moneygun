import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

// Requests notification permission status from the native app and updates the UI.
export default class extends BridgeComponent {
  static component = "notification-permission"
  static targets = ["status", "message"]

  connect() {
    super.connect()
    this.send("connect", {}, (message) => {
      const data = message?.data || message
      this.#updateUI(data?.status, data?.platform)
    })
  }

  #updateUI(status, platform) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = this.#statusText(status)
      this.statusTarget.dataset.status = status || "unknown"
    }

    if (this.hasMessageTarget) {
      this.messageTarget.textContent = this.#statusMessage(status, platform)
    }
  }

  #statusText(status) {
    return {
      granted: "✅ Enabled",
      denied: "❌ Disabled",
      not_determined: "⏳ Not Set",
      provisional: "🔕 Provisional",
      ephemeral: "⏱️ Temporary"
    }[status] || "❓ Unknown"
  }

  #statusMessage(status, platform) {
    const platformName = platform === "ios" ? "iOS" : "Android"

    return {
      granted: `Push notifications are enabled on this ${platformName} device.`,
      denied: `Push notifications are disabled. Enable them in ${platformName} Settings.`,
      not_determined: "Push notification permission has not been requested yet.",
      provisional: "Push notifications are provisionally enabled (quiet notifications).",
      ephemeral: "Push notifications are temporarily enabled for this App Clip."
    }[status] || "Unable to determine push notification status."
  }
}

