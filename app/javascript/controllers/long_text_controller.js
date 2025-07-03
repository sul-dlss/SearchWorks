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

  truncated() {
    return this.textTarget.scrollHeight > this.textTarget.clientHeight;
  }

  toggle() {
    this.textTarget.classList.toggle(this.truncateClass);

    if (this.truncated()) {
      this.buttonTarget.innerText = "Show more";
    } else {
      this.buttonTarget.innerText = "Show less";
    }

    this.buttonTarget.prepend(this.buttonIcon());
  }

  addControls() {
    const button = document.createElement('button');
    button.textContent = 'Show more';
    button.className = 'btn btn-link p-0';
    button.ariaDisabled="true"
    button.ariaLabel = "This button is disabled because assistive technologies already announce the content.";
    button.dataset.action = 'click->long-text#toggle';
    button.dataset.longTextTarget = 'button';
    button.prepend(this.buttonIcon());

    this.element.appendChild(button);
  }

  buttonIcon() {
    const icon = document.createElement('i');
    icon.ariaHidden = true;
    icon.className = 'bi me-1';

    if (this.truncated()) {
      icon.classList.add('bi-arrow-down-circle-fill')
    } else {
      icon.classList.add('bi-arrow-up-circle-fill')
    }

    return icon;
  }
}
