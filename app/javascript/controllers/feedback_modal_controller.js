import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="feedback-modal"
export default class extends Controller {
  
  async showToast(event) {
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(document.getElementById('toast'))
    toastBootstrap.show()
    this.closeModal()
  }

  closeModal() {
    document.getElementById('blacklight-modal').close()
  }
}
