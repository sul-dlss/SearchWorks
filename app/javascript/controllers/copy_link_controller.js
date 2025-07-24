import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-link"
export default class extends Controller {
  static values = {
    url: String
  }

  async copyLink() {
    try {
        await navigator.clipboard.writeText(this.urlValue)
        const toast = document.getElementById('toast-template').content.cloneNode(true).querySelector('.toast');
        const toastText = toast.querySelector('.toast-text')
        toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Link copied to clipboard'
        document.getElementById('toast-area').appendChild(toast)
        bootstrap.Toast.getOrCreateInstance(toast).show()
    } catch (err) {
        console.error('Failed to copy text: ', err);
    }
  }
}
