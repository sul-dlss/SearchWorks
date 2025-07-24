import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback-modal"
export default class extends Controller {
  closeModal() {
    document.getElementById('blacklight-modal').close()
  }
}
