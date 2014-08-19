Blacklight.onLoad(function(){

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
          var $element = $(this.element);
          $element.on('change', function(){
            var $currentCount = $('span#current-selections-count');
            var currentCount = parseInt($currentCount.text(), 10);
            var showList = $("li#show-list");
            var clearList = $("li#clear-list");

            if ($element.is(':checked')) {
              currentCount += 1;
            } else {
              currentCount -= 1;
            }

            if (currentCount < 0) currentCount = 0;
            $currentCount.text(currentCount);

            // Adds/removes disabled class based off of selections
            if (currentCount === 0){
              if (!selectionsPage()) {
                showList.addClass("disabled");
              }
              clearList.addClass("disabled");
            } else {
              if (!selectionsPage()){
                showList.removeClass("disabled");
              }
              clearList.removeClass("disabled");
            }

          });
        }
    };

    function selectionsPage() {
      return window.location.pathname === "/selections";
    }


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
