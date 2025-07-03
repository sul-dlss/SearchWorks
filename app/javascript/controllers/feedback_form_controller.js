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
    const response = await event.detail.fetchResponse.response.json()
    this.displayResponse(response)
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
  displayResponse(responseJSON) {
    const messageType = responseJSON[0][0]
    const message = responseJSON[0][1]
   
    if (this.isStandalone()) {
      this.displayAlert(messageType, message)
      this.hideForm()
    } else {
      this.displayToast(messageType, message)
      this.closeModal()
    }
  }


  displayAlert(messageType, message) {
    const alertType = (messageType == 'error') ? 'danger' : messageType
    const iconClass = this.messageIcon(messageType)
    const flashHtml = `
      <div class="alert alert-${alertType} alert-dismissible shadow-sm d-flex align-items-center">
        <div class="text-body">
          <div><i class="bi ${iconClass} me-2"></i> ${message}</div>
        </div>
        <button type="button" class="btn-close p-2 mt-1" data-bs-dismiss="alert" aria-label="Close"></button>
      </div>`

    // Show the flash message
    document.querySelector('div.flash_messages').innerHTML = flashHtml
  }

  // The toast appears on the modal page
  // Perhaps this could be done by associating this controller with the toast as well
  // but unclear how "this.element" would resolve
  displayToast(messageType, message) {
    const toast = document.getElementById('toast')
    const toastText = toast.querySelector('.toast-text')
    const iconClass = this.messageIcon(messageType)
    const brokenOutMessage = this.breakoutMessageForToast(message)
    toastText.innerHTML = `<i class="bi ${iconClass} me-2"></i> ${brokenOutMessage}`
    const toastBootstrap = bootstrap.Toast.getOrCreateInstance(toast)
    toastBootstrap.show()
  }

  messageIcon(messageType) {
   return (messageType == "error") ? "bi-exclamation-triangle-fill": "bi-check-circle-fill" 
  }

  breakoutMessageForToast(message) {
    // If there is an element in strong at the beginning, put on its own line
    const beginTag = "<strong>"
    const endTag = "</strong>"
    if(message.startsWith(beginTag)) {
      const endIndex = message.indexOf(endTag) + endTag.length
      return message.substring(0, endIndex) + "<br>" + message.substring(endIndex + 1, message.length)
    }
    return message
  }

  // This hides all the content, including the heading portion and not just the form itself
  hideForm() {
    document.querySelector("div.standalone").classList.add('d-none')
  }

  closeModal() {
    document.querySelector("dialog#blacklight-modal").close()
  }
}
