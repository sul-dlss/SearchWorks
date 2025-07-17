import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-more-button"
export default class extends Controller {
  showToast(e) {
    const toast = document.getElementById('toast');
    if (!toast) return;

    const toastText = document.getElementById('toast-text');
    toastText.innerHTML = e.detail.html;

    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toast)
    toastBootstrap.show()
  }
}
