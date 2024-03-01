import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-table"
// This hides rows after the first 5.
export default class extends Controller {
  connect() {
    this.collapse()
  }

  get children() {
    return Array.from(this.element.children)
  }

  // Called by long_table_collapse 
  expand() {
    this.children.forEach((childElement) => childElement.hidden = false)
  }

  // Called by long_table_collapse 
  collapse() {
    this.children.forEach((childElement, index) => {
      childElement.hidden = (index >= 5)
    })
  }
}
