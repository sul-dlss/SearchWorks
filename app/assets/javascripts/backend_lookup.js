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

    function updateText(count, el){
      countText = $("<span>...finds " + count + " results</span>");
      $(el).after(countText);
    }
    Plugin.prototype = {

        init: function() {
          var el = this;
          $url = $(el.element).data('lookup');
          if(el.onScreen()){
            el.lookupResults();
          } else {
            $(document).on('scroll', function(){
              if(el.onScreen()){
                el.lookupResults();
              }
            });
          }
        },
        onScreen: function(){
          var el = $(this.element);
          var viewport = {};
          viewport.top = $(window).scrollTop();
          viewport.bottom = viewport.top + $(window).height();
          var bounds = {};
          bounds.top = el.offset().top;
          bounds.bottom = bounds.top + el.outerHeight();
          return ((bounds.top <= viewport.bottom) && (bounds.bottom >= viewport.top));
        },
        lookupResults: function(){
          var el = this.element;
          if(!$(el).data(pluginName + '_processed')) {
            $(el).data(pluginName + '_processed', true);
            $.getJSON($url, function(data){
              $response = data.response;
              $total_count = parseInt($response.pages.total_count).toLocaleString();
              updateText($total_count, el);
            });
          }
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
