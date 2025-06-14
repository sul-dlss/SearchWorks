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
    console.log(dimensions)
    window.gtag('event', 'click', dimensions)
  }
}
