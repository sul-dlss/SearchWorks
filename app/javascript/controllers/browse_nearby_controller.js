import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="browse-nearby"
export default class extends Controller {
  static targets = ["container", "tabs", "fullPage"]

  connect() {
    this.addActiveClasses(this.tabsTarget.querySelector("button.active"))
    this.resizeWithAside()
  }

  setActive(event) {
    this.addActiveClasses(event.target)
    this.removeActiveClasses(event.relatedTarget)

    if (this.hasFullPageTarget) this.fullPageTarget.href = event.target.dataset.fullPageUrl
  }

  resizeWithAside() {
    this.isAsideBlocking() ? this.containerTarget.classList.remove("breakout") : this.containerTarget.classList.add("breakout")
  }

  addActiveClasses(element) {
    if (element) element.classList.add("bi", "bi-check2")
  }

  removeActiveClasses(element) {
    if (element) element.classList.remove("bi", "bi-check2")
  }

  getAsideTarget() {
    return document.getElementById("aside")
  }

  isAsideBlocking() {
    const aside = this.getAsideTarget()
    if (!aside) return false
    if (window.innerWidth < 992) return true

    const asideBottom = aside.getBoundingClientRect().bottom
    const browseNearbyTop = this.containerTarget.getBoundingClientRect().top - 32

    return asideBottom > browseNearbyTop
  }
}
