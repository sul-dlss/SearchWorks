import { Controller } from "@hotwired/stimulus"

// Paginates long facet lists in a modal
export default class extends Controller {
  static targets = [ "list" , "next", "prev"]

  perPage = 20
  currentPage = 1

  connect() {
    this.items = Array.from(this.listTarget.children)
    this.total = this.items.length
    this.maxPage = Math.ceil(this.total / this.perPage)

    this.paginate()
    // When the modal is closed, we need to clear our list of items, because a different facet may be opened.
    // The list of items here acts as a cache.
    document.addEventListener("hide.blacklight.blacklight-modal", () => this.close())
  }

  // Self-destruct the node that owns this controller and replace it with an empty div.
  close() {
    const modalContent = document.createElement("div")
    modalContent.classList.add("modal-content")
    this.element.replaceWith(modalContent)
  }

  previous() {
    this.currentPage = Math.max(1, this.currentPage - 1)
    this.paginate()
  }

  next() {
    this.currentPage = Math.min(this.maxPage, this.currentPage + 1)
    this.paginate()
  }

  paginate() {
    const firstRecord = (this.currentPage - 1) * this.perPage
    const lastRecord = this.currentPage * this.perPage

    this.items.forEach((elem, recordNum) => {
      elem.hidden = !(recordNum >= firstRecord && recordNum < lastRecord)
    })

    this.prevTarget.disabled = this.currentPage <= 1
    this.nextTarget.disabled = this.currentPage >= this.maxPage

  }

  sortAlpha() {
    this.items.sort((a, b) => {
      const textA = a.textContent.toUpperCase()
      const textB = b.textContent.toUpperCase()
      return textA < textB ? -1 : textA > textB ? 1 : 0
    })

    this.listTarget.innerHTML = ''
    this.items.forEach(item => this.listTarget.appendChild(item))
    this.paginate()
  }

  sortNum() {
    this.items.sort((b, a) => {
      const countA = this.intValue(a.querySelector('.facet-count').textContent)
      const countB = this.intValue(b.querySelector('.facet-count').textContent)
      return countA - countB
    })

    this.listTarget.innerHTML = '';
    this.items.forEach(item => this.listTarget.appendChild(item))
    this.paginate()
  }

  intValue(str) {
    return Number.parseInt(str.replace(/,/g, ''))
  }
}
