import { BridgeComponent } from "@hotwired/hotwire-native-bridge"

export default class extends BridgeComponent {
  static component = "nav"
  static targets = ["item"]

  connect() {
    super.connect()

    const items = this.itemTargets.map(item => {
      return {
        title: item.innerText,
        image: item.dataset.image || 'none',
        selector: `a[href="${item.getAttribute("href")}"]`,
        url: item.getAttribute("href")
      }
    })


    console.log("items:", items)

    const element = this.bridgeElement
    const title = element.bridgeAttribute("title") || 'menu'
    const side = element.bridgeAttribute("side") || "left"
    const image = element.bridgeAttribute("image") || "none"

    this.send("connect", {items, title, image, side}, (object) => {
      // When this is returned from the Bridge side, the object
      // will be populated with a data attribute, within which is 
      // a selector attribute that contains the selector string
      // that identifies which itemTarget we should click.
      document.querySelector(object.data.selector).click()
    })  
  }
}
