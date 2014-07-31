$(function(){

  //Finds all of the location panels and instantiates jQuery plugin for each one
  $('[data-hours-route]').each(function(i,val){
    $(val).locationHours(); 
  });
})


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
            if (data.error) {
              $(hoursElement).html(data.error);
              return;
            }
            if (data === null){
              return;
            }
            var open = getOpen(data[0]);
            var close = getClose(data[0]);
            var text = "Today's hours: " + open + " - " + close;
            $(hoursElement).html(text);
          });
        }
    };

    function getOpen(data){
      var open = new Date(data.opens_at);
      open = formatHour(open.getHours());
      return open;
    }

    function getClose(data){
      var close = new Date(data.closes_at);
      close = formatHour(close.getHours());
      return close;
    }

    function formatHour(hour){
      if (hour >= 12) {
        if (hour === 12) {
          hour = hour + 'p';
        }else{
          hour = hour - 12 + 'p';
        }
      }else{
        if (hour === 0){
          hour = '12a';
        }else{
          hour = hour + 'a';
        }
      }
      return hour;
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
