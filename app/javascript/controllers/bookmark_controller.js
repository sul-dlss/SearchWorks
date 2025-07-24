import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark"
export default class extends Controller {
  static targets = ['icon', 'checkedIcon', 'hoverIcon']

  hover() {
    if (this.checked()) {
      this.checkedIconTarget.classList.add('d-none');
      this.hoverIconTarget.classList.remove('d-none');
    }
  }

  checked() {
    return this.element.querySelector('input[type="checkbox"]').checked
  }

  blur() {
    this.checkedIconTarget.classList.remove('d-none');
    this.hoverIconTarget.classList.add('d-none')
  }

  bookmarkUpdated(event) {
    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    if (event.detail.checked){
      this.element.ariaLabel = 'Remove from saved records';
      toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Record saved'
      if (this.element.matches(':hover')) this.hover()
    } else {
      this.element.ariaLabel = 'Save record';
      toastText.innerHTML =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Record removed'
    }
    this.element.dispatchEvent(new CustomEvent('update-tooltip', { bubbles: true}))
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }
}
