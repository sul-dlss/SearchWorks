// Inspired by and modified from http://railsapps.github.io/rails-google-analytics.html

GoogleAnalytics = (function() {
  function GoogleAnalytics() {}

  GoogleAnalytics.load = function() {
    GoogleAnalytics.analyticsId = GoogleAnalytics.getAnalyticsId();
    (function(i, s, o, g, r, a, m) {
      i['GoogleAnalyticsObject'] = r;
      i[r] = i[r] || function() {
        (i[r].q = i[r].q || []).push(arguments);
      };

      i[r].l = 1 * new Date;

      a = s.createElement(o);
      m = s.getElementsByTagName(o)[0];

      a.async = 1;
      a.src = g;
      m.parentNode.insertBefore(a, m);
    })(window, document, 'script', '//www.google-analytics.com/analytics.js', 'ga');
    ga('create', GoogleAnalytics.analyticsId, 'auto');
  };

  GoogleAnalytics.trackPageview = function(url) {
    if (!GoogleAnalytics.isLocalRequest()) {
      return ga('send', {
          hitType: 'pageview',
          page: location.pathname
        }
      );
    }
  };

  GoogleAnalytics.isLocalRequest = function() {
    return GoogleAnalytics.documentDomainIncludes("local");
  };

  GoogleAnalytics.documentDomainIncludes = function(str) {
    return document.domain.indexOf(str) !== -1;
  };

  GoogleAnalytics.getAnalyticsId = function() {
    return $("[data-analytics-id]").data('analytics-id');
  };

  return GoogleAnalytics;

})();

Blacklight.onLoad(function(){
  GoogleAnalytics.load();
  if (GoogleAnalytics.analyticsId){
    GoogleAnalytics.trackPageview();
  }

  $('.iiif-dnd').on('click', function(e) {
    var manifest = $(e.currentTarget).data().manifest;
    ga('send', 'event', 'IIIF DnD', 'yo', manifest, {
      'transport': 'beacon',
    });
  });

  $('.iiif-dnd').on('dragstart', function(e) {
    var manifest = $(e.currentTarget).data().manifest;
    ga('send', 'event', 'IIIF DnD', 'dragged', manifest, {
      'transport': 'beacon'
    });
  });

  // Track external link clicks
  $('a[href]:not([href^="/"],[href^="#"],[data-behavior="requests-modal"],[href=""])').on('click', function(e) {
    ga('send', 'event', 'External link', 'clicked', this.href, {
      'transport': 'beacon'
    });
    if ($('.zero-results').length > 0) {
      ga('send', 'event', 'Zero results', 'clicked', this.href, {
        'transport': 'beacon'
      });
    }
  });

  $('a[data-track="zero-results-remove-limit"]').on('click', function(e) {
    ga('send', 'event', 'Zero results', 'clicked-remove-limit', this.href, {
      'transport': 'beacon'
    });
  });

  $('a[data-track="zero-results-search-all-fields"]').on('click', function(e) {
    ga('send', 'event', 'Zero results', 'clicked-search-all-fields', this.href, {
      'transport': 'beacon'
    });
  });

  // When an alternate catalog is loaded, track those link clicks
  $('[data-alternate-catalog]').on('alternateResultsLoaded', function(event) {
    $(event.currentTarget).find('a').on('click', function(e) {
      var eventCategory = $('.zero-results').length > 0 ? 'Zero results' : 'Alternate Results';
      ga('send', 'event', eventCategory, 'clicked-alternate-results', this.href, {
        'transport': 'beacon'
      });
    });
  });

  // Just track when a zero results page gets loaded
  $('.zero-results').each(function() {
    ga('send', 'event', 'Zero results', 'loaded', this.href, {
      'transport': 'beacon'
    });
  });

  // Featured resources on home page
  $('.catalog-home-page .features a').on('click', function(e) {
    ga('send', 'event', 'Featured resource', 'clicked', this.href, {
      'transport': 'beacon'
    });
  });
});
