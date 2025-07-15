import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-more-button"
export default class extends Controller {
  connect() {
    this.element.textContent = 'Show more'
    this.element.classList.add('btn', 'btn-link', 'p-0', 'mb-3', 'show-more-button')
    this.element.ariaDisabled = true
    this.element.ariaExpanded = false
    this.element.ariaLabel = "This button is disabled because assistive technologies already announced the content."
    this.element.prepend(this.buttonIcon())
  }

  isTruncated() {
    return !this.element.ariaExpanded
  }

  buttonIcon() {
    const icon = document.createElement('i')
    icon.ariaHidden = true
    icon.className = 'bi me-1'

    if (this.isTruncated()) {
      icon.classList.add('bi-arrow-down-circle-fill')
    } else {
      icon.classList.add('bi-arrow-up-circle-fill')
    }

    return icon
  }

  expand() {
    this.element.innerText = "Show less"
    this.element.ariaExpanded = true
    this.element.prepend(this.buttonIcon())

    this.dispatch('expand');
  }

  collapse() {
    this.element.innerText = "Show more"
    this.element.ariaExpanded = false
    this.element.prepend(this.buttonIcon())

    this.dispatch('collapse');
  }

  toggle() {
    if (this.isTruncated()) {
      this.expand();
    } else {
      this.collapse()
    }
  }
}
