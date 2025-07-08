import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bookmark"
export default class extends Controller {
  static targets = ['icon', 'form']

  get checkedValue() {
    return this.formTarget.dataset.bookmarkCheckedValue == 'true'
  }

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

    // The saved records page handles updates (only removals) by doing a full page refresh.
    if (window.location.pathname.startsWith('/selections')) {
      Turbo.visit(document.baseURI, { action: 'replace' })
    } else {
      this.displayToast(!this.checkedValue)
    }
  }

  displayToast(added) {
    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    if (added) {
      toastText.innerHTML = '<i class="bi bi-check-circle-fill pe-1" aria-hidden="true"></i> Saved to bookmarks'
    } else {
      toastText.innerHTML =  '<i class="bi bi-trash-fill pe-1" aria-hidden="true"></i> Removed from bookmarks'
    }
    bootstrap.Toast.getOrCreateInstance(toast).show()
  }

  animateRemovals(event) {
    if (event.detail.newElement == null && event.target.dataset.animateExit && !event.target.dataset.animateExitStarted) {
      event.target.dataset.animateExitStarted = true // prevent multiple animations
      event.preventDefault();

      this.animateExit(event.target);
    }
  }

  async animateExit(target) {
    target.animate(
      [
        {
          transform: `scale(1)`,
          transformOrigin: "top",
          height: 'auto',
          opacity: 1.0,
        },
        {
          transform: `scaleY(0)`,
          transformOrigin: "top",
          height: 0,
          opacity: 0,
        },
      ],
      {
        duration: 600,
        easing: "ease-out",
      }
    )
    await Promise.all(
      target.getAnimations().map((animation) => animation.finished)
    )
    target.remove()
    this.displayToast(false)
  }
}
