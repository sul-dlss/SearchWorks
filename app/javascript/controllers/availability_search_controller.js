import { Controller } from "@hotwired/stimulus"

// search results item availability display
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
    this.callnumberElements.forEach((element) => {
      if (element.dataset.originalContent) {
        element.innerHTML = element.dataset.originalContent;
      } else {
        element.dataset.originalContent = element.innerHTML;
      }

      if (element.textContent.toLowerCase().includes(searchTerm.toLowerCase())) {
        element.innerHTML = element.textContent.replace(
          new RegExp(this.escape(searchTerm), 'gi'),
          (match) => `<mark class="p-0 bg-body fw-bold">${match}</mark>`
        );
      }
    });

    this.libraryElements.forEach((element) => {
      const badge = element.querySelector('h2 .badge');
      if (!badge) return;

      if (badge.dataset.originalContent) {
        badge.innerHTML = badge.dataset.originalContent;
      } else {
        badge.dataset.originalContent = badge.innerHTML;
      }

      const matches = document.createElement('span');
      const count = element.querySelectorAll('.item-row:has(mark)').length;
      matches.innerHTML = ` | ${count} match${count == 1 ? '' : 'es'}`;

      badge.appendChild(matches);
    });
    
  }

  resetSearch() {
    this.element.classList.remove('search-mode');
    this.callnumberElements.forEach((element) => {
      if (element.dataset.originalContent) {
        element.innerHTML = element.dataset.originalContent;
      }
    });

    this.libraryElements.forEach((element) => {
      const badge = element.querySelector('h2 .badge');

      if (!badge) return;

      if (badge.dataset.originalContent) {
        badge.innerHTML = badge.dataset.originalContent;
      }
    });
  }

  get callnumberElements() {
    return this.element.querySelectorAll('.callnumber')
  }

  get libraryElements() {
    return this.element.querySelectorAll('.accordion-item')
  }
}
