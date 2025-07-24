import { Controller } from "@hotwired/stimulus"
import Blacklight from 'blacklight-frontend'

// Connects to data-controller="email-sent"
export default class extends Controller {
  done() {
    this.element.closest('dialog')
    Blacklight.Modal.hide()
    const toast = document.getElementById('toast-template').content.cloneNode(true).querySelector('.toast');
    const toastText = toast.querySelector('.toast-text')
    toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Email sent'
    document.getElementById('toast-area').appendChild(toast)
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }
}
