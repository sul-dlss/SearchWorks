Blacklight.onLoad(function(){
  //Finds all of the location panels and instantiates jQuery plugin for each one
  $('[data-hours-route]').each(function(i,val){
    $(val).locationHours();
  });
});


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin to find hours for a specific library's hours

      Usage: $(selector).locationHours();

    No available options

    This plugin :
      - queries the SearchWorks hours api
      - parses the response and adds hours information to the appropriate library
      location access panel
  */

    var pluginName = "locationHours";

    function Plugin( element, options ) {
        this.element = element;
        this.options = $.extend( {}, options) ;
        this._name = pluginName;

        this.init();
    }

    function getHoursElement(element) {
      return $(element).find("div.location-hours-today");
    }

    Plugin.prototype = {

        init: function() {
          var element = this.element;
          var hoursElement = getHoursElement(this.element);
          var libLocation = $(this.element).data('hours-route');
          $.getJSON(libLocation, function(data){
            if (data === null || !("hours" in data)){
              return;
            }
            if (data.error) {
              $(hoursElement).html(data.error);
              return;
            }
            $(hoursElement).html(data.hours);
          });
        }
    };

    function getOpen(data){
      var open = new Date(data.opens_at);
      open = formatTime(open.toLocaleTimeString());
      return open;
    }

    function getClose(data){
      var close = new Date(data.closes_at);
      close = formatTime(close.toLocaleTimeString());
      return close;
    }

    function formatTime(time){
      var re = /:00|m|\s/gi;
      time = time.replace(re, '').toLowerCase();
      return time;
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
