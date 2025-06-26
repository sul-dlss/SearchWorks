import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark-toast"
export default class extends Controller {
  bookmarkUpdated(e) {
    let toastHTML = '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Removed from bookmarks'
    if (e.detail.checked){
      toastHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Saved to bookmarks'
    } 
    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    toastText.innerHTML = toastHTML
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }
}
