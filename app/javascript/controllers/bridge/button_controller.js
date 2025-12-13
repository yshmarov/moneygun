import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
// Source:
// https://native.hotwired.dev/ios/bridge-components
// Docs:
// https://blog.corsego.com/hotwire-native-bridge-button

// Example:
// Text button:
// <a href="/posts" data-controller="bridge--button" data-bridge-title="Posts">
//   Posts
// </a>
// 
// Icon button:
// <a href="/posts" data-controller="bridge--button" data-bridge-title="Posts" data-bridge-ios-image="play.circle">
//   Posts
// </a>
// 
// Icon button on the left (right by default):
// <a href="/posts" data-controller="bridge--button" data-bridge-title="Posts" data-bridge-ios-image="play.circle" data-bridge-side="left">
//   Posts
// </a>
// 
// Text with a click event:
// <div data-controller="bridge--button" data-bridge-title="Search" data-bridge-ios-image="magnifyingglass.circle" class="hidden" data-action="click->dialog#open">
//   Search
// </div>
export default class extends BridgeComponent {
  static component = "button"

  connect() {
    super.connect()

    const element = this.bridgeElement
    const title = element.bridgeAttribute("title")
    const image = element.bridgeAttribute("ios-image")
    const side = element.bridgeAttribute("side") || "right"
    this.send("connect", { title, image, side }, () => {
      this.element.click()
    })
  }

  disconnect() {
    super.disconnect()
    this.send("disconnect")
  }
}
