import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-text"
export default class extends Controller {
  static targets = ["button", "text"]
  static classes = ["truncate"]
  static values = { showMoreButtonStyle: String }

  connect() {
    this.textTarget.classList.add(this.truncateClass);

    // we don't bother with truncating the text if it is already short enough that
    // the toggle button takes up as much space as the text itself.. this
    // has the convenient side-effect that we don't need to monitor for
    // page resizing because truncated text should always be long enough
    // to need the toggle.
    if (this.textTarget.scrollHeight < (this.textTarget.clientHeight + 40)) {
      this.textTarget.classList.remove(this.truncateClass);
    } else {
      this.addControls();
      this.setTabIndexFor(this.hiddenLinks(), -1);
    }
  }

  expand() {
    this.textTarget.classList.remove(this.truncateClass);
    this.setTabIndexFor(this.links());
  }

  collapse() {
    this.textTarget.classList.add(this.truncateClass);
    this.setTabIndexFor(this.hiddenLinks(), -1);
  }

  addControls() {
    // keeps the show more button appearing twice on back/forward browser action
    if (this.element.querySelector('.show-more-button')) return;

    const button = document.createElement('button');
    button.dataset.controller = 'show-more-button'
    button.dataset.action = 'show-more-button#toggle';
    if (this.showMoreButtonStyleValue) button.dataset.showMoreButtonStyleValue = this.showMoreButtonStyleValue;

    this.element.dataset.action = `${this.element.dataset.action} show-more-button:expand->long-text#expand show-more-button:collapse->long-text#collapse`;

    this.element.appendChild(button);
  }

  links() {
    return this.textTarget.querySelectorAll('a')
  }

  hiddenLinks() {
    const truncatedRect = this.textTarget.getBoundingClientRect()
    const visibleBottom = truncatedRect.top + this.textTarget.clientHeight
    const hiddenLinks = []

    this.links().forEach(link => {
      const isHidden = link.getBoundingClientRect().top > visibleBottom

      if (isHidden) {
        hiddenLinks.push(link)
      }
    })

    return hiddenLinks
  }

  setTabIndexFor(links, value = null) {
    links.forEach(link => value ? link.setAttribute('tabindex', value) : link.removeAttribute('tabindex'))
  }
}
