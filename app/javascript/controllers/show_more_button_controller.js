import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="show-more-button"
export default class extends Controller {
  static values = { style: { type: String, default: "icon-button" } }
  connect() {
    this.element.ariaDisabled = "true"
    this.element.ariaExpanded = "false"
    this.element.ariaLabel = "Show more (note: this button is disabled because assistive technologies already announced the content)."

    switch (this.styleValue) {
      case "text-button":
        this.setupTextButton()
        break
      default:
        this.setupIconButton()
    }
  }

  setupTextButton() {
    this.element.textContent = "more"
    this.element.classList.add("btn", "btn-link", "p-0", "m-0", "show-more-button")
  }

  setupIconButton() {
    this.element.textContent = "Show more"
    this.element.classList.add("btn", "btn-link", "p-0", "show-more-button")
    this.element.prepend(this.buttonIcon())
  }

  isTruncated() {
    return this.element.ariaExpanded == "false"
  }

  buttonIcon() {
    const icon = document.createElement("i")
    icon.ariaHidden = true
    icon.className = "bi me-1"

    if (this.isTruncated()) {
      icon.classList.add("bi-arrow-down-circle-fill")
    } else {
      icon.classList.add("bi-arrow-up-circle-fill")
    }

    return icon
  }

  expand() {
    this.element.ariaExpanded = "true"

    if (this.styleValue == "icon-button") {
      this.element.innerText = "Show less"
      this.element.ariaLabel = this.element.ariaLabel.replace("Show more", "Show less")
      this.element.prepend(this.buttonIcon())
    } else {
      this.element.textContent = "less"
    }

    this.dispatch("expand")
  }

  collapse() {
    this.element.ariaExpanded = "false"

    if (this.styleValue == "icon-button") {
      this.element.innerText = "Show more"
      this.element.ariaLabel = this.element.ariaLabel.replace("Show less", "Show more")
      this.element.prepend(this.buttonIcon())
    } else {
      this.element.textContent = "more"
    }

    this.dispatch("collapse")
  }

  toggle() {
    if (this.isTruncated()) {
      this.expand()
    } else {
      this.collapse()
    }
  }
}
