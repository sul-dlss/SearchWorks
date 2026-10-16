import { Controller } from "@hotwired/stimulus"
import { Toast } from "bootstrap"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    this.toast = Toast.getOrCreateInstance(this.element)

    this.toast.show()
  }

  destroy() {
    this.element.remove()
  }
}
