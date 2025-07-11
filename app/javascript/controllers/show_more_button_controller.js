import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-more-button"
export default class extends Controller {
  connect() {
    this.truncatedClass = 'content-truncated'
    this.element.textContent = 'Show more';
    this.element.classList.add('btn', 'btn-link', 'p-0', 'mb-3', this.truncatedClass, 'show-more-button');
    this.element.ariaDisabled="true"
    this.element.ariaExpaned="false"
    this.element.ariaLabel = "This button is disabled because assistive technologies already announce the content.";
    this.element.prepend(this.buttonIcon());
  }

  truncated() {
    return this.element.classList.contains(this.truncatedClass)
  }

  buttonIcon() {
    const icon = document.createElement('i');
    icon.ariaHidden = true;
    icon.className = 'bi me-1';

    if (this.truncated()) {
      icon.classList.add('bi-arrow-down-circle-fill')
    } else {
      icon.classList.add('bi-arrow-up-circle-fill')
    }

    return icon;
  }

  toggle() {
    if (this.truncated()) {
      this.element.classList.remove(this.truncatedClass)
      this.element.innerText = "Show less";
      this.element.ariaExpaned="true"
    } else {
      this.element.classList.add(this.truncatedClass)
      this.element.innerText = "Show more";
      this.element.ariaExpaned="false"
    }

    this.element.prepend(this.buttonIcon());
  }
}