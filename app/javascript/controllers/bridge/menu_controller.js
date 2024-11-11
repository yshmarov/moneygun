import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
import { BridgeElement } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "menu"
  static targets = [ "title", "item" ]

  show(event) {
    if (this.enabled) {
      event.stopImmediatePropagation()
      this.notifyBridgeToDisplayMenu(event)
    }
  }

  notifyBridgeToDisplayMenu(event) {
    const title = new BridgeElement(this.titleTarget).title
    const items = this.makeMenuItems(this.itemTargets)

    this.send("display", { title, items }, message =>  {
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