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
      return $(element).find(".location-hours-today");
    }

    Plugin.prototype = {

        init: function() {
          const hoursElement = getHoursElement(this.element);
          const libLocation = $(this.element).data('hours-route');
          $.getJSON(libLocation, function(data){
            if (data.error) {
              $(hoursElement).html(data.error);
              return;
            }
            if (data === null){
              return;
            }
            const open = formatTime(data[0].opens_at);
            const close = formatTime(data[0].closes_at);
            const closed = data[0].closed;
            $(hoursElement).html(formatTimeRange(open, close, closed));
          });
        }
    };

    function formatTimeRange(open, close, closed) {
      if (closed) {
        return "Closed today"
      } else if (open == '12a' && close == '11:59p') {
        return "Open 24hr today"
      } else {
        return "Today's hours: " + open + " - " + close;
      }
    }

    function formatTime(dateString) {
      const date = new Date(dateString);
      const shortTime = new Intl.DateTimeFormat('en-US', {
        timeZone: 'America/Los_Angeles',
        timeStyle: 'short'
      }).format(date);
      const shortTimeComponents = shortTime.split(' ');
      const formattedHoursAndMinutes = shortTimeComponents[0].replace(':00', '');
      const formattedMeridian = shortTimeComponents[1] === 'AM' ? 'a' : 'p';
      return formattedHoursAndMinutes + formattedMeridian;
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
