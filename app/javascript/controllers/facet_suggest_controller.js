import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-suggest"
export default class extends Controller {
  static targets = ["query"]


  connect() {
    // If a parameter has been passed in the URL, we want to initiate
    // the facet suggest based on that parameter
    this.loadExistingQuery()
  }

  loadExistingQuery() {
    const inputElement = this.inputElement()
    if (inputElement.value != "") {
      // There needs to be an input event for the query to be applied and have the Blacklight FacetSuggest respond
      // correctly, removimg the previous and next links if applicable
      const event = new Event("input", { bubbles: true })
      inputElement.dispatchEvent(event)
    }
  }


  // When the user clicks on the button to select a sorting option,
  // this method captures what is currently in the input field and
  // appends them to the sorting URLs to allow for that query to
  // be passed along with the sorting option
  handleSort() {
    this.queryTargets.forEach(query => {
      const url = new URL(query.href)
      url.searchParams.set("facet_suggest_query", this.inputElement().value)
      query.href = url.href
    })
  }

  inputElement() {
    // This is needed rather than this.element because the modal rewrites the DOM
    return document.querySelector(".modal-body input.facet-suggest")
  }
}
