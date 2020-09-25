(function($) {

  /*
    jQuery plugin to for fetching the live lookup

      Usage: $(selector).liveLookup();
  */


  $.fn.liveLookup = function() {
    var live_lookup_url = liveLookupURL(this);
    if($('[data-live-lookup-url]').length > 0) {
      return liveLookupRequest();
    }

    function liveLookupRequest() {
      $.getJSON(live_lookup_url, function(data){
          for (var i=0, length=data.length; i < length; i++) {
            var live_data = JSON.parse(data[i]);
            var dom_item = $("[data-barcode='" + live_data.barcode + "']");
            var target = $(dom_item.data('status-target'), dom_item);
            var current_location = $('.current-location', dom_item)
            var status_text = target.next('.status-text');
            if ( live_data.current_location ) {
              current_location.html(live_data.current_location);
            }
            if ( live_data.due_date ) {
              current_location.append(' Due ' + live_data.due_date);
            }

            if ( live_data.due_date && (target.hasClass('unknown') || target.hasClass('page')) ) {
              target.removeClass('unknown');
              target.removeClass('page');
              target.addClass('unavailable');
              status_text.text(''); // The due date/current location acts as the status text at this point
              if (target.attr('title')) {
                target.attr('title', status_text.data('unavailable-text'));
              }
              if ( dom_item.data('request-url') ) {
                var link = $(
                  "<a rel='nofollow' class='btn btn-default btn-xs request-button' href='" + dom_item.data('request-url') + "'>Request</a>"
                );
                $('.request-link', dom_item).html(link);
                link.requestsModal();
              }
            }
            if ( !live_data.due_date && dom_item.length > 0  && target.hasClass('unknown')) {
              target.removeClass('unknown');
              target.addClass('available');
              status_text.text(status_text.data('available-text'));
              if (target.attr('title')) {
                target.attr('title', status_text.data('available-text'));
              }
            }
          }
      });

    }
    function liveLookupURL(container) {
      var root_path = $('[data-live-lookup-url]').data('live-lookup-url');
      var ids = [];
      var id_list = listOfIds(container);
      for(i=0; i<id_list.length; i++) {
        ids.push('ids[]=' + id_list[i]);
      }
      return root_path + '?' + ids.join('&')
    }
    function listOfIds(container){
      var ids = [];
      $('[data-live-lookup-id]', container).each(function(){
        ids.push($(this).data('live-lookup-id'));
      });
      return $.unique(ids);
    }
  }

})(jQuery);


Blacklight.onLoad(function() {
  $('body').liveLookup();
});
