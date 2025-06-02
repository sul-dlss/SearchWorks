import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="managed-purl"
export default class extends Controller {
  static targets = [ "listItem" ]

  connect() {
    this.embedIframe(this.element.querySelector('button'))
  }
  activate(e) {
    this.listItemTargets.forEach((li) => li.classList.remove('active'))
    this.embedIframe(e.target)
  }

  embedIframe(button) {
    button.parentElement.classList.add('active')
    const data = button.dataset
    const provider = data.embedProvider.replace(/\/embed$/, '/iframe')
    const url = `${provider}?url=${data.embedTarget}&hide_title=true&maxheight=500`
    const embedArea = document.querySelector('.managed-purl-embed')
    embedArea.innerHTML = `<iframe src="${url}" frameborder=0 width="100%" scrolling="no" ` +
    `allowfullscreen=true style="height: 520px;"><iframe>`
  }
}
