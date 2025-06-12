document.addEventListener('turbo:load', function() {
  initializeAnalytics()
  addPageLoadAnalytics()
})

document.addEventListener('turbo:frame-load', function() {
  addTurboFrameAnalytics()
})

function addPageLoadAnalytics() {
  // Track engagement with IIIF icon
  document.querySelectorAll('.iiif-dnd').forEach(function(el) {
    el.addEventListener('dragstart', function(e) {
      sendAnalyticsEvent({
        category: 'IIIF DnD',
        action: 'SW/dragged',
        label: (e.currentTarget).data().manifest
      })
    })
  })

  // Track an action when the user clicks on an accordion
  document.querySelectorAll('[data-action="accordion-section#toggle"]').forEach(function (el) {
    el.addEventListener('click', function (e) {
      sendAnalyticsEvent({
        category: 'Accordion',
        action: 'SW/accordion-toggle',
        label: getText(e)
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

  // Featured resources on home page
  trackInternalLinkClicks('.catalog-home-page .features a', 'featured-resource')

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
      label: $(e.currentTarget).parent().find('h3').text().trim()
    })
  })
  $('.facet-content').on('show.bs.collapse', function(e) {
    sendAnalyticsEvent({
      category: 'Facet',
      action: 'SW/expanded-facet',
      label: $(e.currentTarget).parent().find('h3').text().trim()
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

  // Stacks Map Tool Events
  // Stacks Map Opened (from find-it button)
  trackInternalLinkClicks('.stackmap-find-it', 'find-it-button', { includeLinkUrl: false })

  // Stacks Map Opened (from location link)
  trackInternalLinkClicks('.location-name a', 'find-it-location', { includeLinkUrl: false })

  document.querySelectorAll('.show-description a').forEach(function(el) {
    el.addEventListener('click', function(e) {
      sendAnalyticsEvent({
        category: 'Stacks Map',
        action: 'SW/Text Description Opened'
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
}

function addTurboFrameAnalytics() {
  // Browse-nearby
  trackInternalLinkClicks('.embedded-items .gallery-document a', 'browse-nearby', { includeLinkUrl: false, includeLinkText: false })
}

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

function initializeAnalytics() {
  window.dataLayer = window.dataLayer || [];
  window.gtag = function() { dataLayer.push(arguments); }
  gtag('js', new Date());

  // gtag set property and config
  const config = { cookie_flags: 'SameSite=None;Secure' }
  // To turn off analytics debug mode, exclude the parameter altogether (cannot just set to false)
  //See https://support.google.com/analytics/answer/7201382?hl=en#zippy=%2Cgoogle-tag-websites
  if (document.head.querySelector("meta[name=analytics_debug]").getAttribute('value') === "true") {
    config.debug_mode = true;
  }
  gtag('config', 'G-FH5WNQS9B5', config);
}

// GA4 tracks outbound links by default. This function can be used to track
// internal link clicks utilizing the exact same set of dimensions. Please
// be judicious. GA4 warns that performance and reporting capabilities may
// be reduced when reaching 50,000+ unique values. For example it would be
// bad practice to use this function to track catalog result links without
// disabling the link_url dimension, as those links would have many unique
// values in that dimension.
// Despite looking like a boolean, outbound is a text field.
// GA4 sets outbound to the literal string "true" for outgoing links.
// https://support.google.com/analytics/table/13594742#query=link
function trackInternalLinkClicks(selector, type = "false", options = {}) {
  const defaultOptions = {
    includeLinkDomain: true,
    includeLinkUrl: true,
    includeLinkId: true,
    includeLinkClasses: true,
    includeLinkText: true
  }
  const config = { ...defaultOptions, ...options }

  document.querySelectorAll(selector).forEach(function(el) {
    if (el.hostname == window.location.hostname) {
      el.addEventListener('click', function(e) {
        console.log("click", type)
        const dimensions = { outbound: type }
        if (config.includeLinkDomain) dimensions.link_domain = window.location.hostname
        if (config.includeLinkUrl) dimensions.link_url = e.currentTarget.href
        if (config.includeLinkId && e.currentTarget.id) dimensions.link_id = e.currentTarget.id
        if (config.includeLinkClasses) dimensions.link_classes = e.currentTarget.className
        if (config.includeLinkText) dimensions.link_text = e.currentTarget.innerText.trim()
        window.gtag && window.gtag('event', 'click', dimensions)
      });
    }
  });
}
