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
      $.ajax(element.data().collectionMembersPath).success(function(data) {
        element.html(data.html);

        // Trigger filmstrip rendering and preview
        element.find('.image-filmstrip').renderFilmstrip();
        element.find('*[data-behavior="preview-filmstrip"]').previewFilmstrip();

        _this.showAndUpdateDigitalContentCount(data);
      });
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
