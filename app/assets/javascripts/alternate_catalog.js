(function (global) {
  var AlternateCatalog = {
    init: function(el) {
      var $el = $(el);
      var data = $el.data();
      var $documents = $('#documents');
      var $title = $el.find('.alternate-catalog-title');
      var $body = $el.find('.alternate-catalog-body');
      var $count = $el.find('.alternate-catalog-count');
      var $close = $el.find('.alternate-catalog-close');
      var $facets = $el.find('.alternate-catalog-facets');

      // Setup close click handler
      $close.click(function () {
        $el.hide();
      });

      // Insert between the 3rd and 4th document
      var afterThird = $documents.find('.document-position-2').after($el);
      // If there is no third document, just append to the end of #documents
      if (afterThird.length === 0) {
        $documents.append($el);
      }

      // Update title
      $title.text('Searching...')

      // Try other catalog
      $.getJSON({
        url: data.alternateCatalog
      }).done(function (response) {
        var count = response.response.pages.total_count;
        if (count > 0) {
          // Update title
          $title.text('Your search also found results in');
          $count.text(parseInt(count).toLocaleString());
          // Update body
          var facetHtml = createFacets(response.response.facets, data.alternateCatalog);
          $facets.html(facetHtml);
          $body.show();
        } else {
          $title.text('No additional results were found in');
          $body.find('a.btn').remove();
          $body.find('dl').remove();
          $body.show();
        }
      });
    }
  };

  function createFacets(facets, url) {
    var facetLinks = [];
    // Iterating over everything here would be too slow
    var sourceOrResouce = facets.filter( function(facet) {
      return facet.label === 'Source type' || facet.label === 'Resource type'
    })
    sourceOrResouce.forEach(function (facet) {
      var count = 0;
      // Iterating over everything here would be even slower.. sort it and take
      // the top5
      var topFive = facet.items.sort(function(a, b) {
        return b.hits - a.hits;
      }).slice(0, 5);
      topFive.forEach(function (item) {
        linkedUrl = url + '&f[' + facet.name + '][]=' + encodeURI(item.value);
        linkText = item.label + ' (' + parseInt(item.hits).toLocaleString() + ')';
        facetLinks.push('<a href="' + linkedUrl + '">' + linkText + '</a>');
      });
    });
    return facetLinks.join(' - ')
  }

  global.AlternateCatalog = AlternateCatalog;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-alternate-catalog]').each(function (i, element) {
    AlternateCatalog.init(element);
  });
});
