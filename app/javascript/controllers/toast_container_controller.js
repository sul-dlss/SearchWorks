import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toast-message-listener"
export default class extends Controller {
  showToast(e) {
    const toast = document.getElementById('toast-template').content.cloneNode(true).querySelector('.toast');
    if (!toast) return;

    const toastText = toast.querySelector('.toast-text');
    toastText.innerHTML = e.detail.html;

    document.getElementById('toast-area').appendChild(toast);
  }
}
