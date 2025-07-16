import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="database-autocomplete"
export default class extends Controller {
  static targets = ['input', 'frame']
  static values = {
    url: String
  }

  search() {
    if (this.inputTarget.value.length < 3) {
      this.frameTarget.innerHTML = '';
      return;
    }

    const uri = new URL(this.urlValue);
    uri.searchParams.set('q', this.inputTarget.value);
    if (!this.frameTarget.querySelector('a')) this.addLoadingPlaceholder();
    this.frameTarget.src = uri.toString();
    this.frameTarget.classList.remove('d-none');
    this.inputTarget.setAttribute('aria-expanded', 'true');
  }

  show() {
    this.frameTarget.classList.remove('d-none');

    if (this.frameTarget.querySelector('a')) {
      this.inputTarget.setAttribute('aria-expanded', 'true');
    }
  }

  addLoadingPlaceholder() {
    const placeholder = document.createElement('div');
    placeholder.classList.add('text-center', 'p-3', 'fst-italic', 'ms-4', 'suggestion-results');
    placeholder.innerHTML = 'Loading...';
    this.frameTarget.innerHTML = '';
    this.frameTarget.appendChild(placeholder);
  }

  esc() {
    this.inputTarget.focus();
    this.frameTarget.classList.add('d-none');
    this.inputTarget.setAttribute('aria-expanded', 'false');
  }

  previous(e) {
    e.preventDefault();
    e.stopPropagation();

    const items = [].concat(...this.frameTarget.querySelectorAll('a'));

    if (!items.length) {
      return
    }

    const currentIndex = items.indexOf(e.target);

    if (currentIndex < 1) {
      return items[items.length - 1].focus();
    } else {
      items[currentIndex - 1].focus();
    }
  }

  next(e) {
    e.preventDefault();
    e.stopPropagation();
    const items = [].concat(...this.frameTarget.querySelectorAll('a'));

    if (!items.length) {
      return
    }

    if (!items.includes(e.target)) {
      return items[0].focus();
    }

    const currentIndex = items.indexOf(e.target);

    if (currentIndex >= items.length - 1) {
      console.log(items[0]);
      return items[0].focus();
    } else {
      items[currentIndex + 1].focus();
    }
  }
}
