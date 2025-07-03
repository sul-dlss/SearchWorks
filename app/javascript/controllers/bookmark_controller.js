import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark"
export default class extends Controller {
  static targets = ['icon']
  static values = { checked: Boolean }

  hover() {
    if (this.checkedValue) {
      this.iconTarget.style.setProperty('--bl-icon-color', 'var(--stanford-digital-red-light)')
      this.iconTarget.classList.remove('bi-bookmark-check-fill')
      this.iconTarget.classList.add('bi-bookmark-dash-fill')
    }
  }

  blur() {
    if (this.checkedValue) {
      this.iconTarget.style.removeProperty('--bl-icon-color')
      this.iconTarget.classList.remove('bi-bookmark-dash-fill')
      this.iconTarget.classList.add('bi-bookmark-check-fill')
    }
  }

  bookmarkUpdated(event) {
    if (!event.detail.success) {
      console.error('Bookmark update failed:', event.detail.error);
      return;
    }

    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    if (this.checkedValue){
      toastText.innerHTML =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Removed from bookmarks'
    } else {
      toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Saved to bookmarks'
    }
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }
}
