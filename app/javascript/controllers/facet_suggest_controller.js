import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="facet-suggest"
export default class extends Controller {
  static targets = ['input', 'count', 'alphabetical']


  connect() {
    // If a parameter has been passed in the URL, we want to initiate
    // the facet suggest based on that parameter
    this.loadExistingQuery()
  }

  loadExistingQuery() {
    if(this.inputTarget.value != "") {
      // There needs to be an input event for the query to be applied and have the Blacklight FacetSuggest respond
      // correctly, removimg the previous and next links if applicable
      const event = new Event('input', { bubbles: true })
      this.inputTarget.dispatchEvent(event)
    }
  }


  // When the user clicks on the button to select a sorting option,
  // this method captures what is currently in the input field and 
  // appends them to the sorting URLs to allow for that query to 
  // be passed along with the sorting option
  handleSort() {
    const countUrl = new URL(this.countTarget.href)
    const alphabeticalUrl =  new URL(this.alphabeticalTarget.href)
    const countParams = new URLSearchParams(countUrl.search)
    const alphabeticalParams = new URLSearchParams(alphabeticalUrl.search)
    countParams.set('facet_suggest_query', this.inputTarget.value)
    alphabeticalParams.set('facet_suggest_query', this.inputTarget.value)
    countUrl.search = countParams
    alphabeticalUrl.search = alphabeticalParams
    this.countTarget.href = countUrl.href
    this.alphabeticalTarget.href = alphabeticalUrl.href
  }
}