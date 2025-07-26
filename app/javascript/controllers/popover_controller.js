import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    document.addEventListener("click", this.handleClickOutside.bind(this));
  }

  hidePopover() {
    const triggerBtn = document.querySelector(`[aria-describedby="${this.element.id}"]`)
    const popover = bootstrap.Popover.getInstance(triggerBtn)
    if (popover) popover.hide()
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hidePopover();
    }
  }
}