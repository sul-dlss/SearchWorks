import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-text"
export default class extends Controller {
  static targets = ['text']

  async copy() {
    try {
        await navigator.clipboard.write([new ClipboardItem({ "text/html": this.textTarget.innerHTML, "text/plain": this.textTarget.innerText })])
        window.dispatchEvent(new CustomEvent('show-toast', { detail: { html: '<i class="bi bi-check" aria-hidden="true"></i> Copied' } }));
    } catch (err) {
        console.error('Failed to copy text: ', err);
    }
  }
}
