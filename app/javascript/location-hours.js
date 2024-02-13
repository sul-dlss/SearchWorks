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
            var closed = data[0].closed;
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

    function getLibraryTimezoneDate(dateString) {
      const date = new Date(dateString);
      const formatter = new Intl.DateTimeFormat('en-US', {
        timeZone: 'America/Los_Angeles',
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit',
        second: '2-digit'
      });
      return new Date(formatter.format(date));
    }

    function getOpen(data){
      let open = getLibraryTimezoneDate(data.opens_at);
      open = formatTime(open.getHours(), open.getMinutes());
      return open;
    }

    function getClose(data){
      let close = getLibraryTimezoneDate(data.closes_at);
      close = formatTime(close.getHours(), close.getMinutes());
      return close;
    }

    function formatTime(hours, minutes){
      var ampm = (hours >= 12 && hours !== 24) ? 'p' : 'a';
      hours = hours % 12;
      var hoursFormated = (hours === 0) ? '12' : hours.toString();
      var minutesFormated = formatMinutes(minutes);
      return hoursFormated + minutesFormated + ampm;
    }

    function formatMinutes(minutes){
      var minutesFormated;
      if (minutes === 0){
        minutesFormated = '';
      } else {
        if (minutes.toString().length === 1){
          minutesFormated = ':0' + minutes;
        }else{
          minutesFormated = ':' + minutes;
        }
      }
      return minutesFormated;
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
