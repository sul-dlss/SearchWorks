import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="copy-text"
export default class extends Controller {
  static targets = ['text']

  async copy(event) {
    try {
      await navigator.clipboard.write([new ClipboardItem({ "text/html": this.textTarget.innerHTML, "text/plain": this.textTarget.innerText })])
      if (event.target.classList.contains('copied')) {
        return
      }

      const originalCopyButtonText = event.target.innerHTML
      event.target.classList.add('copied')
      event.target.innerHTML = '<i class="bi bi-check" aria-hidden="true"></i>Copied'

      setTimeout(() => {
        if (event.target && event.target.isConnected) {
          event.target.innerHTML = originalCopyButtonText
          event.target.classList.remove('copied')
        }
      }, 8000)
    } catch (err) {
        console.error('Failed to copy text: ', err);
    }
  }
}
