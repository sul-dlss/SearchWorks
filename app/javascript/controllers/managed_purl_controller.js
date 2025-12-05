import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="managed-purl"
export default class extends Controller {
  static targets = ["button", "item", "embed"]

  connect() {
    this.embedIframe(this.buttonTargets[0])
  }

  switchItem(event) {
    this.itemTargets.forEach(item => item.classList.remove("active"))
    this.embedIframe(event.currentTarget)
  }

  embedIframe(button) {
    button.parentElement.classList.add("active")
    const data = button.dataset
    const provider = data.embedProvider.replace(/\/embed$/, "/iframe")
    const url = `${provider}?url=${data.embedTarget}&hide_title=true&maxheight=500`

    this.embedTarget.innerHTML = `<iframe src="${url}" frameborder=0 width="100%" scrolling="no" ` +
      'allowfullscreen=true style="height: 520px;"><iframe>'
  }
}
