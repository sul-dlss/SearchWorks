import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { countId: String, total: String }

  connect() {
    document.getElementById(this.countIdValue).innerText = this.totalValue;
    const popovers = document.querySelectorAll('[data-bs-toggle="popover"]')
    popovers.forEach(popoverTriggerEl => new bootstrap.Popover(popoverTriggerEl))
  }
}
