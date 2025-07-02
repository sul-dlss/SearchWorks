// app/javascript/controllers/facet_offcanvas_controller.js
import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-offcanvas"
export default class extends Controller {
  connect() {
    this.updateDrawerDirection()
    window.addEventListener("resize", this.updateDrawerDirection.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.updateDrawerDirection.bind(this))
  }

  updateDrawerDirection() {
    const smBreakpoint = 576
    const offcanvasEl = this.element

    if (window.innerWidth < smBreakpoint) {
      offcanvasEl.classList.remove("offcanvas-start")
      offcanvasEl.classList.add("offcanvas-bottom")
    } else {
      offcanvasEl.classList.remove("offcanvas-bottom")
      offcanvasEl.classList.add("offcanvas-start")
    }
  }
}
