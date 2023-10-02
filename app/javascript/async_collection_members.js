var AsyncCollectionMembers = (function() {
  var selector = '[data-behavior="async-collection-members"]';

  return {
    init: function() {
      var _this = this;
      $.each(this.collectionMemberElements(), function() {
        _this.replaceCollectionMemberContent($(this));
      });
    },

    replaceCollectionMemberContent: function(element) {
      var _this = this;
      var placeholder = '<div class="async-placeholder">' +
                          '<h3 class="col-md-9"></h3>' +
                          '<p class="col-md-6"></p>' +
                          '<p class="col-md-12"></p>' +
                          '<p class="col-md-3"></p>' +
                        '</div>';
      element.html(placeholder);
      fetch(element.data().collectionMembersPath)
        .then((response) => response.json())
        .then((json) => {
          element.hide().html(json.html).fadeIn(500);

          // Trigger filmstrip rendering and preview
          element.find('*[data-behavior="preview-filmstrip"]').previewFilmstrip();
  
          _this.showAndUpdateDigitalContentCount(json);
        })
    },

    collectionMemberElements: function() {
      return $(selector);
    },

    showAndUpdateDigitalContentCount: function(data) {
      $('[data-behavior="display-digital-content-count"][data-document-id="' + data.id + '"]').show();
      var updateEl = $('[data-behavior="update-digital-content-count"][data-document-id="' + data.id + '"]');

      if(updateEl.text().match(/\d+/)) {
        return;
      }
      // Assuming an simple pluralization here (we only update item/items in our implementation)
      updateEl.show().text(
         data.total + ' ' + (data.total > 1 ? updateEl.text() + 's' : updateEl.text())
      );
    }
  };
}());

Blacklight.onLoad(function() {
  AsyncCollectionMembers.init();
});
