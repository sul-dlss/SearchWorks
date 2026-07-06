import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="asset-version"
//
// Long-lived tabs never re-request the page, so they can keep running JS
// from weeks-old deploys. Once the page was rendered more than a week ago,
// start checking whether the server is serving a newer revision, and reload
// if so. Age is measured from the server-stamped render time rather than
// from when this script started running, since a page served from the
// browser's disk cache can execute its JS long after it was rendered.
const MAX_AGE_MS = 7 * 24 * 60 * 60 * 1000
const CHECK_INTERVAL_MS = 60 * 60 * 1000

export default class extends Controller {
  static values = { url: String, revision: String, loadedAt: Number }

  connect() {
    this.timer = setInterval(() => this.checkRevision(), CHECK_INTERVAL_MS)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  checkRevision() {
    if (Date.now() - this.loadedAtValue * 1000 < MAX_AGE_MS) return

    fetch(this.urlValue, { cache: "no-store" })
      .then((response) => response.json())
      .then((data) => {
        if (data.revision !== this.revisionValue) window.location.reload()
      })
      .catch((error) => console.error("asset_version fetch failed", error))
  }
}
