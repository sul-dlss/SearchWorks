(function (global) {
  var AlternateCatalog = {
    container: null,
    titleElement: null,

    init: function(el) {
      this.container = $(el);
      this.titleElement = this.container.find('.alternate-catalog-title');

      // Setup close click handler
      this.initCloseButton();

      // Insert between the 3rd and 4th document
      this.injectAlternateCatalogInotResults();

      // Update title
      this.titleElement.text('Searching...')

      // Try other catalog
      this.fetchOtherCatalog();

      // Try LibGuides
      this.fetchLibGuides();
    },

    initCloseButton: function() {
      var $close = this.container.find('.alternate-catalog-close');
      var _this = this;

      $close.click(function () {
        _this.container.hide();
      });
    },

    injectAlternateCatalogInotResults: function() {
      var $documents = $('#documents');
      var afterThird = $documents.find('.document-position-2').after(this.container);
      var _this = this;

      // If there is no third document, just append to the end of #documents
      if (afterThird.length === 0) {
        $documents.append(_this.container);
      }
    },

    fetchOtherCatalog: function() {
      var alternateCatalogUrl = this.container.data().alternateCatalog;
      var $body = this.container.find('.alternate-catalog-body');
      var $count = this.container.find('.alternate-catalog-count');
      var $facets = this.container.find('.alternate-catalog-facets');
      var _this = this;

      $.getJSON({
        url: alternateCatalogUrl
      }).done(function (response) {
        var count = response.response.pages.total_count;
        if (count > 0) {
          // Update title
          _this.titleElement.text('Your search also found results in');
          $count.text(parseInt(count).toLocaleString());
          // Update body
          var facetHtml = createFacets(response.response.facets, alternateCatalogUrl);
          $facets.append(facetHtml);
          $body.show();
          _this.container.trigger('alternateResultsLoaded', $body);
        } else {
          _this.titleElement.text('No additional results were found in');
          $body.find('a.btn').remove();
          $facets.remove();
          $body.show();
        }
      });
    },

    fetchLibGuides: function() {
      var $guidesContainer = this.container.find('[data-lib-guides-api-url]');
      if ($guidesContainer.length === 0) {
        return;
      }
      var $guideList = $guidesContainer.find('ol');
      var libGuidesApiUrl = $guidesContainer.data('libGuidesApiUrl');

      var _this = this;

      $.getJSON({
        url: libGuidesApiUrl
      }).done(function (response) {
        if (response.length > 0) {
          response.forEach(function(guide) {
            $guideList.append(
              '<li><a href="' + guide.url + '">' + guide.name + '</a></li>'
            );
          });
        } else {
          $guidesContainer.remove();
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
        facetLinks.push('<li class="list-inline-item"><a href="' + linkedUrl + '">' + linkText + '</a></li>');
      });
    });
    return facetLinks
  }

  global.AlternateCatalog = AlternateCatalog;
}(this));

Blacklight.onLoad(function () {
  'use strict';

  $('[data-alternate-catalog]').each(function (i, element) {
    AlternateCatalog.init(element);
  });
});
