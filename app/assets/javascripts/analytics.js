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
  });
});
