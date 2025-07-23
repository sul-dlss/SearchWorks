import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast"
export default class extends Controller {
  connect() {
    this.toast = bootstrap.Toast.getOrCreateInstance(this.element);

    this.toast.show();
  }

  destroy() {
    this.element.remove();
  }
}
