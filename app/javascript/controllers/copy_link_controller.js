import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-link"
export default class extends Controller {
  static values = {
    url: String
  }

  async copyLink() {
    try {
        await navigator.clipboard.writeText(this.urlValue)

        window.dispatchEvent(new CustomEvent('show-toast', { detail: { html: '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Link copied to clipboard' } }));
    } catch (err) {
        console.error('Failed to copy text: ', err);
    }
  }
}
