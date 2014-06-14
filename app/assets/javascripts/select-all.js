Blacklight.onLoad(function(){

  //Instantiates select all
  $('#select_all-dropdown').selectAll();
})


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin to select all bookmarks on a page

      Usage: $(selector).selectAll();

    No available options

    This plugin :
      - removes the disabled class for javascript enabled browsers
      - "clicks" the input checkbox for all unselected boxes
  */

    var pluginName = "selectAll";

    function Plugin( element, options ) {
        this.element = element;
        this.options = $.extend( {}, options) ;
        this._name = pluginName;

        this.init();
    }

    Plugin.prototype = {

        init: function() {
          var element = this.element;
          $(element)
            .removeClass("disabled")
            .click(function(){
              $("input.toggle_bookmark").each(function(i,val){
                if ($(val).prop("checked")){
                  return;
                }else{
                  $(val).click();
                }
              });
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
