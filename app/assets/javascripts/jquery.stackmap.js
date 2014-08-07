(function($) {

  /*
    jQuery plugin to query StackMap API and display StackMap content based on response

      Usage: $(selector).stackMap();
  */


  $.fn.stackMap = function() {

    return this.each(function() {
      var $container = $(this),
          stackMapApiUrl = $container.data('stackmap-url'),
          location = $container.data('location'),
          $tplMap = $container.find('.map-template').detach();

      var params = {
        "callno": $container.data('callnumber'),
        "library": $container.data('library'),
        "location": location
      };

      $.getJSON(stackMapApiUrl + '?callback=?', params, function (response) {
        if (response.stat === "OK" && response.results.maps.length > 0) {
          plugContent(response);
        } else {
          $container.html('').html('<p>No map available for this item</p>');
        }
      });

      function plugContent(data) {
        var maps = data.results.maps;

        $container.find('.callnumber').html(data.results.callno);

        $.each(maps, function(index, map) {
          var $tpl = $tplMap.clone(),
              $rangeInfo = $tpl.find('.range-info'),
              $zoomControls = $tpl.find('.zoom-controls'),
              range = map.ranges[0];

          $rangeInfo.find('.library').html(map.library);
          $rangeInfo.find('.floorname').html(map.floorname);
          $rangeInfo.find('.shelving-range').html(range.label);

          if (range.callnoDisplay !== "") {
            $tpl.find('.range-info .callnumber-display').html('(' + range.callnoDisplay + ')');
          }

          $tpl.find('.osd').attr('id', 'osd-' + index);
          $tpl.find('.text-directions').html(map.directions);

          $zoomControls.find('.zoom-in').attr('id', 'zoom-in-' + index);
          $zoomControls.find('.zoom-out').attr('id', 'zoom-out-' + index);
          $zoomControls.find('.zoom-fit').attr('id', 'zoom-fit-' + index);

          $container.append($tpl);
          addOsd(map, index);
          attachEvents(index);
        });
      }

      function addOsd(map, index) {
        var viewer = OpenSeadragon({
          id: 'osd-' + index,
          hash: (new Date()).getTime(),
          tileSources: {
            type: 'legacy-image-pyramid',
            levels:[{
              url: map.mapurl + '&marker=1&type=.png',
              width: map.width,
              height: map.height
            }]
          },
          zoomInButton: 'zoom-in-' + index,
          zoomOutButton: 'zoom-out-' + index,
          homeButton: 'zoom-fit-' + index,
          showFullPageControl: false
        });
      }

      function attachEvents(index) {
        $container.find('.show-description a').click(function(e) {
          var $link = $(this),
              $textSwap = $link.find('.text-swap'),
              $stackmap = $link.parents('.map-template'),
              $osd = $stackmap.find('.osd'),
              $textDirections = $stackmap.find('.text-directions'),
              $zoomControls = $stackmap.find('.zoom-controls');

          if (/show/i.test($textSwap.text())) {
            $textSwap.text('Hide');
            $osd.hide();
            $zoomControls.css('visibility', 'hidden');
            $textDirections.show();
          } else {
            $textSwap.text('Show');
            $osd.show();
            $zoomControls.css('visibility', 'visible');
            $textDirections.hide();
          }

          e.preventDefault();
        });
      }

    });
  }

})(jQuery);


Blacklight.onLoad(function() {
  $('*[data-behavior=stackmap]').stackMap();

  $('#ajax-modal').on('show.bs.modal', function() {
    $('*[data-behavior=stackmap]').stackMap();
  });
});
