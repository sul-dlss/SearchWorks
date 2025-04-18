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
}
