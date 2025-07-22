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

  // this can get removed after https://github.com/projectblacklight/blacklight/pull/3693 is released
  clickedId(){
    if (this.checked()) {
      this.hover()
      this.element.ariaLabel = 'Remove from saved records';
    } else {
      this.element.ariaLabel = 'Save record';
    }
    window.dispatchEvent(new CustomEvent('bookmark-updated', {detail: {checked: this.checked(), document_id: this.element.dataset.documentId}}))
  }

  bookmarkUpdated(event) {
    // lines 36, 40, 43 should get commented in when https://github.com/projectblacklight/blacklight/pull/3693 is released
    // if (event.detail.documentId != this.element.dataset.documentId) return;
    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    if (event.detail.checked){
      //this.element.ariaLabel = 'Remove from saved records';
      toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Record saved'
    } else {
      //this.element.ariaLabel = 'Save record';
      toastText.innerHTML =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Record removed'
    }
    window.dispatchEvent(new CustomEvent('update-tooltip', {}))
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }
}