import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
import { BridgeElement } from "@hotwired/hotwire-native-bridge"
// aka Action Sheet
// open a menu by clicking an HTML element

// Source:
// https://github.com/hotwired/hotwire-native-demo/blob/main/public/javascript/controllers/bridge/menu_controller.js
// Docs:
// https://blog.corsego.com/hotwire-native-bridge-menu-component
export default class extends BridgeComponent {
  static component = "menu"
  static targets = ["title", "item"]

  show(event) {
    if (this.enabled) {
      event.stopImmediatePropagation()
      this.notifyBridgeToDisplayMenu(event)
    }
  }

  notifyBridgeToDisplayMenu(event) {
    const title = new BridgeElement(this.titleTarget).title
    const items = this.makeMenuItems(this.itemTargets)

    this.send("display", { title, items }, message => {
      const selectedIndex = message.data.selectedIndex
      const selectedItem = new BridgeElement(this.itemTargets[selectedIndex])

      selectedItem.click()
    })
  }

  makeMenuItems(elements) {
    const items = elements.map((element, index) => this.menuItem(element, index))
    const enabledItems = items.filter(item => item)

    return enabledItems
  }

  menuItem(element, index) {
    const bridgeElement = new BridgeElement(element)

    if (bridgeElement.disabled) return null

    return {
      title: bridgeElement.title,
      index: index
    }
  }
}
