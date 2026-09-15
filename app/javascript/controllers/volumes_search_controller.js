import { Controller } from "@hotwired/stimulus"

// volume modal search
export default class extends Controller {
  connect() {
  }

  escape(searchTerm) {
    if (RegExp.escape) {
      return RegExp.escape(searchTerm);
    } else {
      // Fallback for older browsers
      return searchTerm.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'); // Escape special characters
    }
  }

  search(event) {
    const searchTerm = event.target.value.trim()
    if (searchTerm === "") {
      return this.resetSearch()
    }

    this.element.classList.add('search-mode');
    const _this = this;
    // Ensuring the regular expression is case insensitive
    const regex = new RegExp(this.escape(searchTerm), 'i');
    this.callnumberElements.forEach((element) => {
      _this.handleElement(searchTerm, element, regex)
    });

    this.titleElements.forEach((element) => {
      _this.handleElement(searchTerm, element, regex)
    });
  }

  handleElement(searchTerm, element, regex) {
    if (element.dataset.originalContent) {
      element.innerHTML = element.dataset.originalContent;
    } else {
      element.dataset.originalContent = element.innerHTML;
    }

    if (element.textContent.toLowerCase().includes(searchTerm.toLowerCase())) {
      element.innerHTML = element.textContent.replace(
        regex,
        (match) => `<mark class="p-0 bg-body fw-bold">${match}</mark>`
      );
    }
  }

  resetSearch() {
    this.element.classList.remove('search-mode');
    this.callnumberElements.forEach((element) => {
      if (element.dataset.originalContent) {
        element.innerHTML = element.dataset.originalContent;
      }
    });
  }

  get callnumberElements() {
    return this.element.querySelectorAll('.callnumber')
  }

  get titleElements() {
    return this.element.querySelectorAll('.title')
  }
}
