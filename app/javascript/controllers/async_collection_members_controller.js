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
          $(this.element).hide().html(json.html).fadeIn(500);

          this.showAndUpdateDigitalContentCount(json);
        })
  }

  showAndUpdateDigitalContentCount(data) {
    $('[data-behavior="display-digital-content-count"][data-document-id="' + data.id + '"]').show();
    var updateEl = $('[data-behavior="update-digital-content-count"][data-document-id="' + data.id + '"]');

    if(updateEl.text().match(/\d+/)) {
      return;
    }
    // Assuming an simple pluralization here (we only update item/items in our implementation)
    updateEl.show().text(
        data.total + ' ' + (data.total > 1 ? updateEl.text() + 's' : updateEl.text())
    )
  }
}
