import { Controller } from "@hotwired/stimulus"

// Behavior for the feedback modal and standalone feedback page
export default class extends Controller {
  static targets = [ 'agent', 'viewport', 'lastSearch' ]

  connect() {
    this.setHiddenFieldValues()
  }

  // Set values for specific fields that are not filled in and must be computed
  setHiddenFieldValues() {
    this.agentTarget.value = navigator.userAgent
    this.viewportTarget.value = 'width:' + window.innerWidth + ' height:' + innerHeight
    // Last search values are available on an item view page
    const lastSearchValue = this.lastSearch()
    if (lastSearchValue != null) {
      this.lastSearchTarget.value = lastSearchValue
    }
  }

  // Get the value of the last search.  Should return URL if on an individual search result page.
  lastSearch() {
    const backToResults = document.querySelector('.back-to-results')

    if(backToResults == null)
      return null

    return backToResults.href
  }
}
