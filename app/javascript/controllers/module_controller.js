import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { countId: String, total: String }

  connect() {
    document.getElementById(this.countIdValue).innerText = this.totalValue;
  }
}
