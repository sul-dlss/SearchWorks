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
          removeAllExistingRequestModals();
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
        addPostMessageListener();
      }

      function removeAllExistingRequestModals() {
        $('.requests-modal').each(function(){
          $(this).remove();
        });
      }

      function applyModalCloseBehavior() {
        modalCancelButton().on('click', function() {
          modalForRequest().modal('hide');
          modalForRequest().remove();
        });
      }

      function addPostMessageListener() {
        var timer;
        $(window).on('message onmessage', function(e) {
          if (timer !== null) { window.clearTimeout(timer); }
          // If we ever extend this to include more data than contentHeight
          // and the successPage boolean then we may want to validate that
          // the event.origin is what we expect it to be. As it stands we
          // are not doing anything that would allow somebody to do anything
          // malicious so we can allow these messages without origin validation.
          var data = e.originalEvent.data;
          updateModalHeight(data.contentHeight);
          updateCancelButton(data.successPage);
          closeModal(data.closeModal);

          // In the case the user has navigated away from the request form
          // (e.g. sso login) we will stop receiving post messages. In
          // this case, we can't know if the height that our modal was last
          // set is tall enough to display all the content. Setting scroll='yes'
          // unfortunately doesn't work w/o reloading the iframe entirely.
          timer = window.setTimeout(function(){
            setIframeToLargeHeight();
          }, 2500);
        });
      }

      function setIframeToLargeHeight(){
        iframeForRequest().height('900px');
      }

      function updateModalHeight(contentHeight) {
        var iframeHeight = iframeForRequest().height();
        var setHeight = parseInt(contentHeight, 10);

        if (iframeHeight != setHeight && contentHeight > 0) {
          iframeForRequest().height(setHeight + 'px');
        }
      }

      function updateCancelButton(onSuccessPage) {
        if (onSuccessPage) {
          modalCancelButton().text('Close');
        }
      }

      function closeModal(shouldClose) {
        if (shouldClose) {
          modalForRequest().modal('hide');
        }
      }

      function modalForRequest() {
        return $('[data-request-modal-url="' + requestURL + '"]');
      }

      function iframeForRequest() {
        return modalForRequest().find('iframe');
      }

      function modalCancelButton() {
        return modalForRequest().find('[data-behavior="cancel-link"]');
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
                  '<iframe width="100%" height="90%" frameborder="0" scrolling="no" src="' + requestURLWithModalParam + '" />',
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
