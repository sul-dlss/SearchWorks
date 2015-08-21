(function(){
  $.fn.requestsModal = function() {

    return this.each(function(){
      var $requestLink = $(this);
      var requestURL = $requestLink.attr('href');
      var requestURLWithModalParam = requestURL + '&modal=true';
      init();

      function init(){
        $requestLink.on('click', function(e){
          e.preventDefault();
          toggleOrCreateModal();
        });
      }

      function toggleOrCreateModal() {
        if ( modalIsPresent() ) {
           showModal();
        } else {
          createModal();
          showModal();
        }
      }

      function showModal() {
        modalForRequest().modal('show');
      }

      function createModal() {
        $('body').append(requestsModalTemplate());
        applyModalCloseBehavior();
      }

      function applyModalCloseBehavior() {
        modalForRequest().find('[data-behavior="cancel-link"]').on('click', function() {
          modalForRequest().modal('hide');
          modalForRequest().remove();
        });
      }

      function modalForRequest() {
        return $('[data-request-modal-url="' + requestURL + '"]');
      }

      function modalIsPresent() {
        return modalForRequest().length > 0;
      }

      function requestsModalTemplate() {
        return [
          '<div class="modal requests-modal" tabindex="-1" role="modal" data-request-modal-url="' + requestURL + '">',
            '<div class="modal-dialog">',
              '<div class="modal-content">',
                '<div class="modal-body">',
                  '<iframe width="100%" height="90%" frameborder="0" src="' + requestURLWithModalParam + '" />',
                  '<div class="form-group cancel-footer">',
                    '<button data-behavior="cancel-link" class="cancel-link btn btn-link">Cancel</button>',
                  '</div>',
                '</div>',
              '</div>',
            '</div>',
          '</div>'
        ].join('\n');
      }
    });
  };

})(jQuery);

Blacklight.onLoad(function() {
  $('[data-behavior="requests-modal"]').requestsModal();
});
