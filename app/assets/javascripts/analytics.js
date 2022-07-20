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
    ga('set', 'anonymizeIp', true);
  };

  GoogleAnalytics.trackPageview = function(url) {
    if (!GoogleAnalytics.isLocalRequest()) {
      return ga('send', {
          hitType: 'pageview',
          page: GoogleAnalytics.getPath()
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

  // Remove the protocol and the host and only return the path with any params
  GoogleAnalytics.getPath = function() {
    return location.href
             .replace(location.protocol + '//' + location.host, '');
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
    ga('send', 'event', 'IIIF DnD', 'clicked', manifest, {
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

  // Side mini-nav
  $('.side-nav-minimap button').on('click', function(e) {
    ga('send', 'event', 'Side mini nav', $(e.currentTarget).text().trim(), GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });

  // Facet collapse - expand events
  $('.facet-content').on('hide.bs.collapse', function(e) {
    ga('send', 'event', 'Facet', 'closed', $(e.currentTarget).parent().find('h3').text().trim(), {
      'transport': 'beacon'
    });
  })
  $('.facet-content').on('show.bs.collapse', function(e) {
    ga('send', 'event', 'Facet', 'expanded', $(e.currentTarget).parent().find('h3').text().trim(), {
      'transport': 'beacon'
    });
  });

  // Cite link
  $('#citeLink').on('click', function(e) {
    ga('send', 'event', 'Cite', 'citation tool opened', {
      'transport': 'beacon'
    });
  });

  // Stacks Map Tool
  $('.stackmap-find-it').on('click', function(e) {
    ga('send', 'event', 'Stacks Map', 'Stacks Map Opened (from find-it button)', {
      'transport': 'beacon'
    });
  });

  $('.location-name a').on('click', function(e) {
    ga('send', 'event', 'Stacks Map', 'Stacks Map Opened (from location link)', {
      'transport': 'beacon'
    });
  });

  $('.show-description a').on('click', function(e) {
    ga('send', 'event', 'Stacks Map', 'Text Description Opened', {
      'transport': 'beacon'
    });
  });

  // Browse-nearby
  $('.index_title a').on('click', function(e) {
    ga('send', 'event', 'Browse-nearby', 'recommendation clicked', {
      'transport': 'beacon'
    });
  });

  // source: http://stackoverflow.com/questions/14035083/jquery-bind-event-on-scroll-stops
  // A.K.A. a debounce function.
  jQuery.fn.scrollStop = function (callback) {
    $(this).scroll(function () {
      var self = this,
        $this = $(self);

      if ($this.data('scrollTimeout')) {
        clearTimeout($this.data('scrollTimeout'));
      }

      $this.data('scrollTimeout', setTimeout(callback, 250, self));
    });
  };

  $('.embedded-items .gallery').scrollStop(function(e) {
    ga('send', 'event', 'Browse-nearby', 'scrolled', { 'transport': 'beacon' });
  });

  // Select / Select all
  // Note: this is counted extra when select-all or unselect-all is also used
  $('input.toggle_bookmark').on('click', function(e) {
    ga('send', 'event', 'Selection', 'select', GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });
  $('span.unselect-all').on('click', function(e) {
    ga('send', 'event', 'Selection', 'unselect-all', GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });
  $('span.select-all').on('click', function(e) {
    ga('send', 'event', 'Selection', 'select-all', GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });

  // Accordion selection / collapse
  $('button[data-accordion-section-target]').on('click', function(e) {
    ga('send', 'event', 'Accordion selection', $(e.currentTarget).text().trim(), GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });

  // View type dropdown
  $('#view-type-dropdown a').on('click', function(e) {
    ga('send', 'event', 'View selection', $(e.currentTarget).text().trim(), GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });

  // Sort by dropdown
  $('#sort-dropdown a').on('click', function(e) {
    ga('send', 'event', 'Sort selection', $(e.currentTarget).text().trim(), GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });

  // Per page dropdown
  $('#per_page-dropdown a').on('click', function(e) {
    ga('send', 'event', 'Per page selection', $(e.currentTarget).text().trim(), GoogleAnalytics.getPath(), {
      'transport': 'beacon'
    });
  });
});
