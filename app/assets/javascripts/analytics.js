// Inspired by and modified from http://railsapps.github.io/rails-google-analytics.html

GoogleAnalytics = (function() {
  function GoogleAnalytics() {}

  GoogleAnalytics.load = function() {
    var firstScript, ga;
    window._gaq = [];
    GoogleAnalytics.analyticsId = GoogleAnalytics.getAnalyticsId();
    window._gaq.push(["_setAccount", GoogleAnalytics.analyticsId]);
    ga = document.createElement("script");
    ga.type = "text/javascript";
    ga.async = true;
    ga.src = ("https:" === document.location.protocol ? "https://ssl" : "http://www") + ".google-analytics.com/ga.js";
    firstScript = document.getElementsByTagName("script")[0];
    firstScript.parentNode.insertBefore(ga, firstScript);
  };

  GoogleAnalytics.trackPageview = function(url) {
    if (!GoogleAnalytics.isLocalRequest()) {
      if (url) {
        window._gaq.push(["_trackPageview", url]);
      } else {
        window._gaq.push(["_trackPageview"]);
      }
      return window._gaq.push(["_trackPageLoadTime"]);
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
    e.preventDefault();
    var link = $(e.currentTarget)
    var manifest = link.data().manifest;
    window._gaq.push(['_trackEvent', 'IIIF DnD', 'clicked', manifest]);
    window.location = link.attr('href');
  });

  $('.iiif-dnd').on('dragstart', function(e) {
    var manifest = $(e.currentTarget).data().manifest;
    window._gaq.push(['_trackEvent', 'IIIF DnD', 'dragged', manifest]);
  });

  // Track external link clicks
  $('a[href]:not([href^="/"],[href^="#"],[data-behavior="requests-modal"],[href=""])').on('click', function(e) {
    e.preventDefault();
    e.stopPropagation();
    var _this = this;
    var link = $(e.currentTarget);
    try {
      if (link[0].host !== window.location.host) {
        window._gaq.push(['_trackEvent', 'External link', 'clicked', link.attr('href')]);
      }
    }
    finally {
      window.location.href = _this.href;
    }
  });
});
