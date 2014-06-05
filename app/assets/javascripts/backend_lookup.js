Blacklight.onLoad(function(){

  $("[data-behavior='backend-lookup']").backendLookup();
})


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin that looksup search results from SearchWorks JSON API and
    appends number of results to link element

      Usage: $(selector).backendLookup();

    No available options

    This plugin :
      - JSON request to link provided in data-lookup attribute
      - appends text with number of results to link
  */

    var pluginName = "backendLookup";

    function Plugin( element, options ) {
        this.element = element;
        var $el, $url, $response, $total_count;

        this.options = $.extend( {}, options) ;
        this._name = pluginName;
        this.init();
    }

    function updateLink(count, el){
      var linkText = $(el).text();
      linkText += " ... found " + count + " results";
      $(el).text(linkText);
    }
    Plugin.prototype = {

        init: function() {
          $url = $(this.element).data('lookup');
          this.lookupResults();
        },
        lookupResults: function(){
          var el = this.element;
          $.getJSON($url, function(data){
            $response = data.response;
            $total_count = $response.pages.total_count;
            updateLink($total_count, el);
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
