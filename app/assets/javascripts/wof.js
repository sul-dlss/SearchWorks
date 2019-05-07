class WoFGeoJSON {
  constructor(wofId) {
    this.wofId = wofId;
  }

  fetch(callback) {
    $.getJSON(this.wofUrl, function(data) {
      if(typeof callback === 'function') {
        callback(data)
      }
    });
  }

  get wofUrl() {
    return `https://data.whosonfirst.org/${this.wofId.substring(0, 3)}/${this.wofId.substring(3, 6)}/${this.wofId.substring(6, 9)}/${this.wofId}.geojson`
  }
}

Blacklight.onLoad(function(){
  $("[data-wof]").each(function() {
    var $el = $(this);
    var $toggleButton = $(this).find('.knowledge-panel-toggle');
    $toggleButton.on('click', function() {
      $(this).toggleClass('fa-plus-circle', !$(this).hasClass('fa-plus-circle'));
      $(this).toggleClass('fa-times-circle', !$(this).hasClass('fa-times-circle'));
      $el.children().each(function() {
        if(!($(this).is($toggleButton) || $(this)[0].nodeName === 'H3')) {
          $(this).toggle();
        }
      });
    });

    var wofId = $el.data().wof.toString();
    var map = L.map($el.find('.wof-show-map').first().attr('id'), {
      attributionControl: false,
      zoomControl: false
    });
    L.tileLayer('https://stamen-tiles-{s}.a.ssl.fastly.net/terrain/{z}/{x}/{y}{r}.{ext}', {
      subdomains: 'abcd',
      minZoom: 0,
      maxZoom: 20,
      ext: 'png'
    }).addTo(map);
    var geojsonLayer;
    new WoFGeoJSON(wofId).fetch((data) => {
      $el.find('.wof-title').text(data.properties['wof:name']);
      geojsonLayer = L.geoJSON(data, {}).addTo(map);
      var bounds = (data.properties['lbl:bbox'] || data.properties['geom:bbox']).split(',');
      map.fitBounds([[bounds[1], bounds[0]], [bounds[3], bounds[2]]]);

      var $dl = $el.find('.wof-show-info dl');
      if(data.properties['wof:hierarchy']) {
        var hierarchy = data.properties['wof:hierarchy'][0];
        $dl.append(`<dt>Located in</dt>`);
        var $ul = $('<ul></ul>');
        for(key in hierarchy) {
          if(['region_id', 'macroregion_id', 'country_id', 'continent_id'].includes(key)) {
            $ul.append(`<li data-hiearchy-wof-id=${hierarchy[key]}></li>`);
          }
        }
        $ul.append(`<li data-hiearchy-wof-id=${hierarchy['locality_id']}></li>`);
        $dl.append($('<dd></dd>').append($ul));
      }

      $el.find('.wof-show-info').html($dl);

      $('[data-hiearchy-wof-id]').each(function() {
        var $li = $(this);
        new WoFGeoJSON($li.data('hiearchy-wof-id').toString()).fetch((data) => {
          var name = $(`<a href="#">${data.properties['wof:name']}</a>`);

          name.on('click', function(e) {
            e.preventDefault();
            map.removeLayer(geojsonLayer);
            geojsonLayer = L.geoJSON(data, {}).addTo(map);
            var bounds = (data.properties['lbl:bbox'] || data.properties['geom:bbox']).split(',');
            map.fitBounds([[bounds[1], bounds[0]], [bounds[3], bounds[2]]]);
          });

          $li.text(`the ${data.properties['wof:placetype']} of `).append(name);
        });
      });
    });
  });


});
