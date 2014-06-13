$(function(){

  //Instantiates select all
  $('input.toggle_bookmark').updateSelectedCount();
})


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin to update the number of selected bookmarks in the toolbar

      Usage: $(selector).updateSelectedCount();

    No available options

    This plugin :
      - adds a listener to each input toggle_bookmark
      - updates the count on change
  */

    var pluginName = "updateSelectedCount";

    function Plugin( element, options ) {
        this.element = element;
        this.options = $.extend( {}, options) ;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function() {
          var element = this.element;
          $(element).on('change', function(){
            var currentCountEl = $('span#current-selections-count');
            var currentCount = parseInt(currentCountEl[0].innerText);
            var status = $(this).prop('checked');
            if (status){
              currentCount ++;
            }else{
              currentCount --;
            }
            $(currentCountEl).html(currentCount);
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
