import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list-toggle"
export default class extends Controller {
  static targets = ['element', 'group']
  connect() {
    if (!this.hasGroupTarget) return
    const ddElements = this.groupTarget.querySelectorAll('dd')
    if (ddElements.length > 5) {
      this.addControls()
      ddElements.forEach(function(element, index) {
        if (index < 5) return
        element.classList.add('d-none')
        element.setAttribute('data-list-toggle-target', 'element')
      })
    }
  }

  addControls() {
    // keeps the show more button appearing twice on back/forward browser action
    if (this.element.querySelector('.show-more-button')) return

    const button = document.createElement('button')
    button.classList.add('mt-0')
    button.dataset.controller = 'show-more-button'
    button.dataset.action = 'click->show-more-button#toggle'

    this.element.dataset.action = `${this.element.dataset.action} show-more-button:expand->list-toggle#expand show-more-button:collapse->list-toggle#collapse`
    // in order for the button to be accessible it needs to be wrapped in a dd.
    // We can't put it outside the dl element because of subject/genre http://localhost:3000/view/in00000385844
    // buttons in a dl element are an accessibility error
    const dd = document.createElement('dd')
    dd.append(button)
    this.groupTarget.append(dd)
  }

  expand() {
    this.elementTargets.forEach(function(element) {
      element.classList.remove('d-none')
    })
  }

  collapse() {
    this.elementTargets.forEach(function(element) {
      element.classList.add('d-none')
    })

    this.element.scrollIntoView()
  }
}
