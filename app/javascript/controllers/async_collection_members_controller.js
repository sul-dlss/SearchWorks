import { Controller } from "@hotwired/stimulus"

// Loads the filmstrip members
export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    this.replaceCollectionMemberContent()
  }

  replaceCollectionMemberContent() {
      const placeholder = '<div class="async-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      this.element.innerHTML = placeholder
      fetch(this.urlValue)
        .then((response) => response.json())
        .then((json) => {
          this.element.style.display = 'none';
          this.element.innerHTML = json.html;
          this.element.style.display = 'block';
          this.element.style.opacity = '0';
          this.element.style.transition = 'opacity 0.5s';
          setTimeout(() => {
            this.element.style.opacity = '1';
          }, 10);

          this.showAndUpdateDigitalContentCount(json);
        })
  }

  showAndUpdateDigitalContentCount(data) {
    const displayElements = document.querySelectorAll('[data-behavior="display-digital-content-count"][data-document-id="' + data.id + '"]');
    displayElements.forEach(el => el.style.display = 'block');

    const updateElements = document.querySelectorAll('[data-behavior="update-digital-content-count"][data-document-id="' + data.id + '"]');

    updateElements.forEach(updateEl => {
      if(updateEl.textContent.match(/\d+/)) {
        return;
      }
      // Assuming an simple pluralization here (we only update item/items in our implementation)
      updateEl.style.display = 'block';
      updateEl.textContent = data.total + ' ' + (data.total > 1 ? updateEl.textContent + 's' : updateEl.textContent);
    });
  }
}
