import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['form', 'reportingFromBanner', 'reportingFromInput', 'userAgentInput', 'viewportInput', 'lastSearchInput']

  connect() {
    this.setHiddenFields()

    // Update href in nav link to '#'
    const trigger = document.querySelector(`*[data-bs-target="#${this.element.id}"]`)
    if (trigger) {
      trigger.setAttribute('href', '#');
    }

    this.reportingFromBannerTarget.textContent = location.href

    // One input for main feedback and one for quick report
    this.reportingFromInputTargets.forEach(input => {
      input.value = location.href
    })

    // Listen for form open and add focus to first form control
    this.element.addEventListener('shown.bs.collapse', () => {
      const firstFormControl = this.formTarget.querySelector('.form-control')
      if (firstFormControl) {
        firstFormControl.focus()
      }
    })
  }

  isFeedbackPath() {
    return (location.href === this.formTarget.action)
  }

  setHiddenFields() {
    // Only add listener if form action is different from current location
    if (this.isFeedbackPath())
      return

    // Set hidden field values
    this.userAgentInputTarget.value = navigator.userAgent
    this.viewportInputTarget.value = `width:${window.innerWidth} height:${window.innerHeight}`

    const backToResultsLinks = Array.from(document.querySelectorAll('.back-to-results'))
    const lastSearchUrls = backToResultsLinks.map(link => link.href).join(',')
    this.lastSearchInputTarget.value = lastSearchUrls

  }

  submitForm(e) {
    if (this.isFeedbackPath())
      return

    e.preventDefault()

    const formData = new FormData(this.formTarget)
    const valuesToSubmit = new URLSearchParams(formData)

    fetch(this.formTarget.action, {
      method: 'POST',
      body: valuesToSubmit,
      headers: {
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.json())
    .then(json => {
      // Hide the collapse element
      const collapseInstance = bootstrap.Collapse.getInstance(this.element)
      if (collapseInstance) {
        collapseInstance.hide()
      } else {
        // Fallback for direct manipulation
        this.element.classList.remove('show')
      }

      // Reset the form
      this.formTarget.reset()

      // Render flash messages
      this.renderFlashMessages(json)
    })
    .catch(error => {
      console.error('Error submitting feedback form:', error)
      this.renderFlashMessages([['error', 'An error occurred while submitting the form. Please try again.']])
    });

    // Reset the recaptcha if it exists
    if (typeof grecaptcha !== 'undefined') {
      grecaptcha.reset()
    }

    return false
  }

  renderFlashMessages(response) {
    const flashContainer = document.querySelector('div.flash_messages')
    if (!flashContainer) return

    // Clear existing messages
    flashContainer.innerHTML = ''

    response.forEach(function(message) {
      const alertType = message[0] === 'error' ? 'danger' : message[0]
      const flashHtml = `
        <div class="alert alert-${alertType} alert-dismissible shadow-sm d-flex align-items-center">
          <div class="text-body">
            <div>${message[1]}</div>
          </div>
          <button type="button" class="btn-close p-2 mt-1" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>`

      flashContainer.innerHTML += flashHtml
    })
  }
}
