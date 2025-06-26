import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-text"
export default class extends Controller {
  static targets = ['text']

  connect() {
  }

  async copy(e) {
    try {
        await navigator.clipboard.writeText(this.textTarget.innerText)
        e.target.closest('button').innerHTML = '<i class="bi bi-check" aria-hidden="true"></i> Copied'
    } catch (err) {
        console.error('Failed to copy text: ', err);
    }
  }
}
