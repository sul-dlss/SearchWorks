Blacklight.onLoad(function(){

  //Instantiates plugin for feedback form

  $("#feedback-form").feedbackForm();
})


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin that handles some of the feedback form functionality

      Usage: $(selector).feedbackForm();

    No available options

    This plugin :
      - changes feedback form link to button
      - submits an ajax request for the feedback form
      - displays alert on response from feedback form
  */

    var pluginName = "feedbackForm";

    function Plugin( element, options ) {
        this.element = element;
        var $el, $form, $action;

        this.options = $.extend( {}, options) ;
        this._name = pluginName;
        this.init();
    }

    function submitListener(){
      // Serialize and submit form if not on action url
      if (location !== $action){
        $($form).on('submit', function() {
          var valuesToSubmit = $(this).serialize();
          $.ajax({
              url: $action,
              data: valuesToSubmit,
              type: 'post'
          }).success(function(response){

            // On success collapse and reset the feedback form
            if (isSuccess(response)){
              $($el).collapse('hide');
              $($form)[0].reset();
            }

            renderFlashMessages(response);


          });
          return false;
        });
      }
    }

    function isSuccess(response){
      switch(response[0][0]){
      case 'success':
        return true;
      default:
        return false;
      }
    }

    function renderFlashMessages(response){
      $.each(response, function(i,val){
        var flashHtml = "<div class='alert alert-" + val[0] + "'><button type='button' class='close' data-dismiss='alert' aria-hidden='true'>&times;</button>" + val[1] + "</div>";

        // Show the flash message
        $('div.flash_messages').html(flashHtml);
      });
    }

    function replaceLink(form, link) {
      var attrs = {};
      $.each(link[0].attributes, function(idx, attr) {
          attrs[attr.nodeName] = attr.value;
      });
      attrs.class = 'cancel-link btn btn-link';

      // Replace the cancel link with a button
      link.replaceWith(function() {
        return $('<button />', attrs).append($(this).contents());
      });

      // Cancel link should not submit form
      form.find('button.cancel-link').on('click', function(e){
        e.preventDefault();
      });
    }

    Plugin.prototype = {

        init: function() {
          $el = $(this.element);
          $form = $($el).find('form');
          $action = $($form).attr('action');
          $cancelLink = $($el).find(".cancel-link");

          // Replace "Cancel" link with link styled button
          replaceLink($el, $cancelLink);

          //Add listener for form submit
          submitListener($el,$form);

          //Update href in nav link to '#'
          $('*[data-target="#' + this.element.id +'"]').attr('href', '#');

          //Updates reporting from fields for current location
          $('span.reporting-from-field').html(location.href);
          $('input.reporting-from-field').val(location.href);

          // Listen for form open and then add focus to message
          $('#feedback-form').on('shown.bs.collapse', function () {
            $("textarea#message").focus();
          });
        }
    };

    // A really lightweight plugin wrapper around the constructor,
    // preventing against multiple instantiations
    $.fn[pluginName] = function ( options ) {
        return this.each(function () {
            if (!$.data(this, "plugin_" + pluginName)) {
                $.data(this, "plugin_" + pluginName,
                new Plugin( this, options ));
            }
        });
    };

})( jQuery, window, document );
