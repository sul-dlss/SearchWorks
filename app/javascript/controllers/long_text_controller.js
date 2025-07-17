import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-text"
export default class extends Controller {
  static targets = ["button", "text"]
  static classes = ["truncate"]

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
    }
  }

  expand() {
    this.textTarget.classList.remove(this.truncateClass);
  }

  collapse() {
    this.textTarget.classList.add(this.truncateClass);
  }

  addControls() {
    // keeps the show more button appearing twice on back/forward browser action
    if (this.element.querySelector('.show-more-button')) return;

    const button = document.createElement('button');
    button.dataset.controller = 'show-more-button'
    button.dataset.action = 'show-more-button#toggle';

    this.element.dataset.action = `${this.element.dataset.action} show-more-button:expand->long-text#expand show-more-button:collapse->long-text#collapse`;

    this.element.appendChild(button);
  }
}
