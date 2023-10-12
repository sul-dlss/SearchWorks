Blacklight.onLoad(function(){

  //Instantiates select all
  $('[data-behavior="recent-selections"]').recentSelections();
})


;(function ( $, window, document, undefined ) {
  /*
    jQuery plugin to get and update the last 3 recently selected items

      Usage: $(selector).recentSelections();

    No available options

    This plugin :
      - listens for the selections dropdown to be activated
      - makes an ajax request to /recent_selections if selections have been updated
        since last request
      - updates list with returned html
  */

    var pluginName = "recentSelections";

    function Plugin( element, options ) {
        this.element = element;
        this.options = $.extend( {}, options) ;
        this._name = pluginName;
        this.updated = true;

        this.init();
    }

    Plugin.prototype = {

        init: function() {
          var plugin = this;
          var element = this.element;
          var url = $(element).data('url');
          $(element).on('show.bs.dropdown', function(){
            plugin.getRecentSelections(url);
          });
        },

        getRecentSelections: function(url){
          var plugin = this;
          var request = $.ajax({
            url: url,
            type: 'GET',
            dataType: 'html'
          });
          request.done(function(html){
            plugin.updateLinks(html);
            plugin.updateList(html);
            $(plugin.element).trigger('updated.selections.dropdown');
          });
        },

        updateLinks: function(html){
          if ($.trim(html) == '') {
            $('#clear-list').addClass('disabled');
          } else {
            $('#clear-list').removeClass('disabled');
          }
        },
        updateList: function(html){
          var addedListItems = $('#show-list [data-attribute="added-list"]');

          if (addedListItems.length > 0) {
            addedListItems.remove(); // Clear out any existing items for replacing
          }

          $("#show-list").prepend(html);
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
