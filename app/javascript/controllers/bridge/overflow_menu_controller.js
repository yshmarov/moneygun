import { BridgeComponent } from "@hotwired/hotwire-native-bridge"
// aka Action Sheet
// open a menu by clicking a Native button

// Source:
// https://github.com/hotwired/hotwire-native-demo/blob/main/public/javascript/controllers/bridge/overflow_menu_controller.js
// Docs:
// https://blog.corsego.com/hotwire-native-bridge-menu-component

// Example:
// <div data-controller="bridge--menu" class="hotwire-native:hidden">
//   <button
//     data-controller="bridge--overflow-menu"
//     data-action="click->bridge--menu#show click->menu#show">
//     Open Menu
//   </button>
//   <p data-bridge--menu-target="title">Select an option</p>
//   <%= link_to "Edit", edit_task_path(@task), data: {"bridge--menu-target": "item"} %>
//   <%= button_to "Destroy", @task, method: :delete, data: {"bridge--menu-target": "item", turbo_confirm: "Are you sure?" } %>
// </div>
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
