// gtag initial setup
window.dataLayer = window.dataLayer || [];
function gtag(){dataLayer.push(arguments);}
gtag('js', new Date());


Blacklight.onLoad(function() {
  // gtag set property and config
  const config = { cookie_flags: 'SameSite=None;Secure' }
  // To turn off analytics debug mode, exclude the parameter altogether (cannot just set to false)
  //See https://support.google.com/analytics/answer/7201382?hl=en#zippy=%2Cgoogle-tag-websites
  if (document.head.querySelector("meta[name=analytics_debug]").getAttribute('value') === "true") {
    config.debug_mode = true;
  }  
  gtag('config', 'G-FH5WNQS9B5', config);

  // Track engagement with IIIF icon
  document.querySelectorAll('.iiif-dnd').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'IIIF DnD',
        action: 'SW/clicked',
        label: (e.currentTarget).data().manifest
      })
    })
  })
 
  document.querySelectorAll('.iiif-dnd').forEach(function(el) {
    el.addEventListener('dragstart', function(e) {
      sendAnalyticsEvent({
        category: 'IIIF DnD',
        action: 'SW/dragged',
        label: (e.currentTarget).data().manifest
      })
    })
  })

  // Track external link clicks
  document.querySelectorAll('a[href*="://"]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'External link',
        action: 'SW/clicked',
        label: this.href
      })
    })
  })

  // Track an action when the user clicks on an accordion
  document.querySelectorAll('[data-accordion-section-target]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      sendAnalyticsEvent({
        category: 'Accordion',
        action: 'SW/accordion-toggle',
        label: getText(e)
      })
    })
  })

  // Track actions when search returns zero results
  document.querySelectorAll('a[data-track="zero-results-remove-limit"]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Zero results',
        action: 'SW/clicked-remove-limit',
        label: this.href
      })
    })
  })

  document.querySelectorAll('a[data-track="zero-results-search-all-fields"]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Zero results',
        action: 'SW/clicked-search-all-fields',
        label: this.href
      })
    })
  })

  // When an alternate catalog is loaded, track those link clicks
  document.querySelectorAll('[data-alternate-catalog]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: document.querySelector(".zero-results") ? 'Zero results' : 'Alternate Results',
        action: 'SW/clicked-alternate-results',
        label: this.href
      })
    })
  })

  // Just track when a zero results page gets loaded, no need for event handler
  document.querySelectorAll('.zero-results').forEach(function(el) {
    sendAnalyticsEvent({
      category: 'Zero results',
      action: 'SW/loaded'
    })
  });
  
  // Featured resources on home page
  document.querySelectorAll('.catalog-home-page .features a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Featured resource',
        action: 'SW/clicked',
        label: this.href
      })
    })
  })

  // Side mini-nav
  document.querySelectorAll('.side-nav-minimap button').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Side mini nav',
        action: 'SW/clicked-side-nav',
        label: getText(e)
      })
    })
  })

  // Facet collapse and expand events
  // I tried to move this file off Jquery but keeping these facet events requires it
  // Bootstrap 3 and 4 event detection depends on Jquery
  // Bootstrap 5 allows for native .addEventListener detection, but only if Jquery is not present at all
  // See https://getbootstrap.com/docs/5.0/getting-started/javascript/ heading "Jquery events"
  // Once this application is on Bootstrap 5, and Jquery is removed, we can change this Bootstrap event detection to pure JS
  $('.facet-content').on('hide.bs.collapse', function(e) {
    sendAnalyticsEvent({
      category: 'Facet',
      action: 'SW/closed-facet',
      label: getText(e)
    })
  })
  $('.facet-content').on('show.bs.collapse', function(e) {
    sendAnalyticsEvent({
      category: 'Facet',
      action: 'SW/expanded-facet',
      label: getText(e)
    })
  })

  // Cite link
  document.querySelectorAll('#citeLink').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Cite',
        action: 'SW/citation tool opened'
      })
    })
  })

  // Stacks Map Tool
  document.querySelectorAll('.stackmap-find-it').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Stacks Map',
        action: 'SW/Stacks Map Opened (from find-it button)'
      })
    })
  })

  document.querySelectorAll('.location-name a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Stacks Map',
        action: 'SW/Stacks Map Opened (from location link)'
      })
    })
  })

  document.querySelectorAll('.show-description a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Stacks Map',
        action: 'SW/Text Description Opened'
      })
    })
  })
  
  // // Browse-nearby
  document.querySelectorAll('.embedded-items .gallery-document a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Browse nearby',
        action: 'SW/recommendation clicked'
      })
    })
  })

  // embedded-call-number-browse.js has code that scrolls to the currently selected item in the gallery on load
  // We want to ignore this initial scroll and only record user actions
  let initial_scroll_complete = false
  const gallery_el =  document.querySelector('.embedded-items .gallery')
  document.querySelectorAll('.embedded-items .gallery').forEach(function(el) {
    el.addEventListener('scroll', function(e) {
      if (initial_scroll_complete) {
        sendAnalyticsEvent({
          category: 'Browse nearby',
          action: 'SW/scrolled'
        })
      }
      setTimeout(() => {
        initial_scroll_complete = true
      }, 1000);
    })
  })
  
  // Select / Select all
  // Note: this is counted extra when select-all or unselect-all is also used
  document.querySelectorAll('input.toggle-bookmark').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Selection',
        action: 'SW/select'
      })
    })
  })

  document.querySelectorAll('span.unselect-all').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Selection',
        action: 'SW/unselect-all'
      })
    })
  })

  document.querySelectorAll('span.select-all').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Selection',
        action: 'SW/select-all'
      })
    })
  })

  // Accordion selection / collapse
  document.querySelectorAll('button[data-accordion-section-target]').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Accordion selection',
        action: 'SW/click',
        label: getText(e)
      })
    })
  })

  // View type dropdown
  document.querySelectorAll('#view-type-dropdown a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'View selection',
        action: 'SW/click',
        label: getText(e)
      })
    })
  })

  // Sort by dropdown
  document.querySelectorAll('#sort-dropdown a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Sort selection',
        action: 'SW/click',
        label: getText(e)
      })
    })
  })

  // Per page dropdown
  document.querySelectorAll('#per_page-dropdown a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Per page selection',
        action: 'SW/click',
        label: getText(e)
      })
    })
  })
});

// Trim the innerHTML text and return
function getText(event) {
  return event.currentTarget.innerText.trim()
}

// Send event in required GA4 format to Google
function sendAnalyticsEvent({ action, category, label, value }) {
  window.gtag && window.gtag('event', action, {
    event_category: category,
    event_label: label,
    event_value: value
  });  
}
