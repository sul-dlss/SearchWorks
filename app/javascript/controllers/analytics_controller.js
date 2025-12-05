import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    category: String
  }

  connect() {
    if (window.gtag !== undefined) return
    const config = { cookie_flags: "SameSite=None;Secure" }
    window.dataLayer = window.dataLayer || []
    window.gtag = function() { dataLayer.push(arguments) }
    gtag("js", new Date())
    // To turn off analytics debug mode, exclude the parameter altogether (cannot just set to false)
    //See https://support.google.com/analytics/answer/7201382?hl=en#zippy=%2Cgoogle-tag-websites
    if (document.head.querySelector("meta[name=analytics_debug]").getAttribute("value") === "true") {
      config.debug_mode = true
    }
    gtag("config", "G-FH5WNQS9B5", config)
  }

  trackBookmark(event) {
    const bookmark = event.currentTarget
    const eventName = bookmark.checked ? "bookmark_added" : "bookmark_removed"
    gtag("event", eventName)
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
    gtag("event", eventName, dimensions)
  }

  trackFacetHide(event) {
    this.trackFacetEvent(event, "facet_hide")
  }

  trackFacetShow(event) {
    this.trackFacetEvent(event, "facet_show")
  }

  trackLink(event) {
    const link = event.currentTarget

    // Only track internal links, GA4 tracks outgoing links automatically.
    if (link.hostname !== window.location.hostname) return

    const dimensions = {
      outbound: this.categoryValue || "false",
      link_classes: link.className,
      link_domain: window.location.hostname,
      link_id: link.id,
      link_text: link.innerText.trim()
    }
    gtag("event", "click", dimensions)
  }

  trackFacetEvent(event, gaEventName) {
    const facetName = this.getTargetFacetName(event.target)
    if (!facetName) return

    const dimensions = {
      facet_name: facetName
    }
    gtag("event", gaEventName, dimensions)
  }

  getTargetFacetName(target) {
    const potentialFacet = target.parentNode
    // We only care about interactions at the top level of a facet, don't capture hierarchical events.
    if (potentialFacet && potentialFacet.classList.contains("facet-limit")) {
      const facetHeading = potentialFacet.querySelector(".facet-field-heading")
      return facetHeading ? facetHeading.textContent.trim() : null
    }
    return null
  }
}
