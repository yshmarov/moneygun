import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
import { BridgeElement } from "@hotwired/hotwire-native-bridge"
// Source:
// https://github.com/hotwired/hotwire-native-demo/blob/main/public/javascript/controllers/bridge/form_controller.js
// Docs:
// https://blog.corsego.com/hotwire-native-form-component

// Replace form_with with bridge_form_with
export default class extends BridgeComponent {
  static component = "form"
  static targets = ["submit"]

  connect() {
    super.connect()
    this.notifyBridgeOfConnect()
  }

  notifyBridgeOfConnect() {
    const submitButton = new BridgeElement(this.submitTarget)
    const submitTitle = submitButton.title

    this.send("connect", { submitTitle }, () => {
      this.submitTarget.click()
    })
  }

  submitStart(event) {
    this.submitTarget.disabled = true
    this.send("submitDisabled")
  }

  submitEnd(event) {
    this.submitTarget.disabled = false
    this.send("submitEnabled")
  }
}
