import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    category: String
  }

  connect() {
    if (window.gtag !== undefined) return
    const config = { cookie_flags: 'SameSite=None;Secure' }
    window.dataLayer = window.dataLayer || []
    window.gtag = function() { dataLayer.push(arguments) }
    gtag('js', new Date())
    // To turn off analytics debug mode, exclude the parameter altogether (cannot just set to false)
    //See https://support.google.com/analytics/answer/7201382?hl=en#zippy=%2Cgoogle-tag-websites
    if (document.head.querySelector("meta[name=analytics_debug]").getAttribute('value') === "true") {
      config.debug_mode = true
    }
    gtag('config', 'G-FH5WNQS9B5', config);
  }

  trackBookmark(event) {
    const bookmark = event.currentTarget
    const eventName = bookmark.checked ? 'bookmark_added' : 'bookmark_removed'
    gtag('event', eventName)
  }

  // A basic "thing" happened. capture the category as the event name and the classes/id/text of the element
  trackEvent(event) {
    const eventName = this.categoryValue || "searchworks"
    const element = event.currentTarget
    const dimensions = {
      link_classes: element.className,
      link_id: element.id,
      link_text: element.innerText.trim()
    }
    gtag('event', eventName, dimensions)
  }

  trackFacetHide(event) {
    const dimensions = {
      facet_name: event.target.parentNode.querySelector('.facet-field-heading').textContent.trim()
    }
    gtag('event', 'facet_hide', dimensions)
  }

  trackFacetShow(event) {
    const dimensions = {
      facet_name: event.target.parentNode.querySelector('.facet-field-heading').textContent.trim()
    }
    gtag('event', 'facet_show', dimensions)
  }

  trackLink(event) {
    const link = event.currentTarget

    // Only track internal links, GA4 tracks outgoing links automatically.
    if (link.hostname !== window.location.hostname) return

    const dimensions = {
      outbound: this.categoryValue || 'false',
      link_classes: link.className,
      link_domain: window.location.hostname,
      link_id: link.id,
      link_text: link.innerText.trim()
    }
    gtag('event', 'click', dimensions)
  }
}
