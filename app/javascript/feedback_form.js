import Blacklight from "blacklight-frontend"

Blacklight.onLoad(function(){

  //Instantiates plugin for feedback form

  const connectionForm = document.getElementById("connection-form")
  if (connectionForm) {
    new FeedbackForm(connectionForm)
  }
})


class FeedbackForm {
  /*
    Feedback form functionality

      Usage: new FeedbackForm(element);

    No available options

    This class :
      - changes feedback form link to button
      - submits an ajax request for the feedback form
      - displays alert on response from feedback form
  */

  constructor(element, options = {}) {
    this.element = element
    this.options = Object.assign({}, options)
    this.init()
  }

  submitListener(el, forms) {
    // Serialize and submit form if not on action url
    forms.forEach((form) => {
      if (location !== form.action) {
        const userAgentInput = form.querySelector("#user_agent")
        const viewportInput = form.querySelector("#viewport")
        const lastSearchInput = form.querySelector("#last_search")

        if (userAgentInput) userAgentInput.value = navigator.userAgent
        if (viewportInput) viewportInput.value = "width:" + window.innerWidth + " height:" + window.innerHeight

        const backToResultsLinks = document.querySelectorAll(".back-to-results")
        const lastSearch = Array.from(backToResultsLinks).map(link => link.href).join()
        if (lastSearchInput) lastSearchInput.value = lastSearch

        form.addEventListener("submit", (e) => {
          e.preventDefault()
          const valuesToSubmit = new URLSearchParams(new FormData(form))
          fetch(form.action, {
            method: "POST",
            body: valuesToSubmit
          }).then((resp) => resp.json())
            .then((json) => {
            // Hide the collapse element
              const collapseElement = bootstrap.Collapse.getInstance(el) || new bootstrap.Collapse(el)
              collapseElement.hide()
              form.reset()
              this.renderFlashMessages(json)
            })

          return false
        })
      }
    })
  }

  isSuccess(response) {
    switch (response[0][0]) {
      case "success":
        return true
      default:
        return false
    }
  }

  renderFlashMessages(response) {
    response.forEach((val) => {
      const alertType = val[0] == "error" ? "danger" : val[0]
      const flashHtml = `
        <div class="alert alert-${alertType} alert-dismissible shadow-sm d-flex align-items-center">
          <div class="text-body">
            <div>${val[1]}</div>
          </div>
          <button type="button" class="btn-close p-2 mt-1" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>`

      // Show the flash message
      const flashMessagesContainer = document.querySelector("div.flash_messages")
      if (flashMessagesContainer) {
        flashMessagesContainer.innerHTML = flashHtml
      }
    })
  }

  init() {
    const el = this.element
    const forms = el.querySelectorAll("form")

    // Add listener for form submit
    this.submitListener(el, forms)

    // Update href in nav link to '#'
    const targetLinks = document.querySelectorAll(`*[data-bs-target="#${this.element.id}"]`)
    targetLinks.forEach(link => {
      link.setAttribute("href", "#")
    })

    // Updates reporting from fields for current location
    const reportingFromSpans = document.querySelectorAll("span.reporting-from-field")
    const reportingFromInputs = document.querySelectorAll("input.reporting-from-field")

    reportingFromSpans.forEach(span => {
      span.innerHTML = location.href
    })

    reportingFromInputs.forEach(input => {
      input.value = location.href
    })

    // Listen for form open and then add focus to message
    this.element.addEventListener("shown.bs.collapse", () => {
      const firstFormControl = forms[0]?.querySelector(".form-control")
      if (firstFormControl) {
        firstFormControl.focus()
      }
    })
  }
}
