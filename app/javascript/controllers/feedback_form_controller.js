import { Controller } from "@hotwired/stimulus"

// Behavior for the feedback modal and standalone feedback page
export default class extends Controller {
  static targets = [ 'agent', 'viewport', 'lastSearch' ]

  // For the modal, connect is fired once the modal is opened
  // For the standalone page, connect is fired on page load
  connect() {
    // Set hidden field values required for submission
    this.setHiddenFieldValues()
    // If standalone, hide feedback link
    if (this.isStandalone()) {
      this.hideFeedbackMenuLink()
    }
  }

  isStandalone() {
    return document.querySelectorAll('.standalone').length > 0
  }

  hideFeedbackMenuLink() {
    document.querySelector('a.nav-link[href="/feedback"]').classList.add('d-none')
  }

  // Attached to the "Send" button via data action for submission event turbo:submit-end
  async submitForm(event) {
    this.displayResponse()
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

  // If success, we need an alert or a toast object to show up
  // If error, we need to display the error in the alert or toast object
  displayResponse() {
    if (this.isStandalone()) {
      this.hideForm()
    } else {
      this.displayToast()
      this.closeModal()
    } 
  }

  // The toast appears on the modal page
  // The contents will be updated by the turbo stream response on form submission
  displayToast() {
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(document.getElementById('toast'))
    toastBootstrap.show()
  }

  // This hides all the content, including the heading portion and not just the form itself
  hideForm() {
    document.querySelector("div.standalone").classList.add('d-none')
  }

  closeModal() {
    document.querySelector("dialog#blacklight-modal").close()
  }
}
