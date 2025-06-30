import scrollOver from "./scroll-over"
import Blacklight from "blacklight-frontend"

Blacklight.onLoad(function () {
  // Set up scroll behavior for tabs, when they are shown
  const tabs = document.querySelectorAll('button[data-bs-toggle="tab"]')
  tabs.forEach((tabEl) => {
    tabEl.addEventListener('shown.bs.tab', function (event) {
      if(!event.target.dataset.start) { return }

      const gallery = document.querySelector(`${event.target.dataset.bsTarget} .gallery`)
      const element = gallery.querySelector(`[data-doc-id="${event.target.dataset.start}"]`)
      scrollOver(element, gallery)
    })
  })
})
