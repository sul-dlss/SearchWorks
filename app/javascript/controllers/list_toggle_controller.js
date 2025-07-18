import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="list-toggle"
export default class extends Controller {
  static values = {
    listItemSelector: { type: String, default: 'dd' },
    limit: { type: Number, default: 5 }
  }
  static targets = ['element', 'group']
  connect() {
    if (!this.hasGroupTarget) return
    const ddElements = this.groupTarget.querySelectorAll(this.listItemSelectorValue)
    if (ddElements.length > this.limitValue) {
      this.addControls()
      ddElements.forEach(function(element, index) {
        if (index < this.limitValue) return
        element.classList.add('visually-hidden')
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
    const dd = document.createElement(this.listItemSelectorValue)
    dd.append(button)
    this.groupTarget.append(dd)
  }

  expand() {
    this.elementTargets.forEach(function(element) {
      element.classList.remove('visually-hidden')
    })
  }

  collapse() {
    this.elementTargets.forEach(function(element) {
      element.classList.add('visually-hidden')
    })

    if (this.element.scrollIntoViewIfNeeded) {
      this.element.scrollIntoViewIfNeeded()
    } else {
      const element = this.element;
      new IntersectionObserver( function( [entry] ) {
        if (entry.intersectionRatio < 1) element.scrollIntoView();
      }).observe(element);
    }
  }
}
