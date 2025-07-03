import { Controller } from "@hotwired/stimulus"
import L from "leaflet"

export default class extends Controller {
  static values = {
    apiUrl: String
  }

  static targets = ["map", "directions"]

  connect() {
    fetch(this.apiUrlValue, { headers: { 'accept': 'application/json' } })
      .then((response) => response.json())
      .then((data) => this.handleResponse(data))
      .catch(console.error)
  }

  handleResponse(data) {
    if (data.results.maps.length > 0) {
      this.plugContent(data)
    } else {
      this.element.innerHTML = '<p>No map available for this item</p>'
    }
  }

  plugContent(data) {
      const maps = data.results.maps

      this.element.querySelector(".callnumber").textContent = data.results.callno

      maps.forEach((map, index) => {
        const tpl = this.mapTarget.cloneNode(true)
        const zoomControls = tpl.querySelector(".zoom-controls")

        this.element.querySelector(".library").textContent = map.library
        this.element.querySelector(".floorname").textContent = map.floorname

        tpl.querySelector(".osd").id = 'osd-' + index
        this.directionsTarget.innerHTML = map.directions.replaceAll('<li>- ', '<li>').replaceAll('<li>-', '<li>')

        const zoomIn = tpl.querySelector(".zoom-in")
        const zoomOut = tpl.querySelector(".zoom-out")
        const zoomFit = tpl.querySelector(".zoom-fit")

        zoomIn.id = 'zoom-in-' + index
        zoomOut.id = 'zoom-out-' + index
        zoomFit.id = 'zoom-fit-' + index

        this.mapTarget.replaceWith(tpl)
        this.addOsd(map, index, zoomControls)
      })
    }
    zoomIn() {
      this.viewer.zoomIn()
    }
    zoomOut(){
      this.viewer.zoomOut()
    }
    zoomBounds(){
      this.viewer.fitBounds(this.bounds)
    }
    addOsd(map, index, zoomControls) {
      this.viewer = L.map('osd-' + index, {
        crs: L.CRS.Simple,
        minZoom: -2,
        zoomControl: false,
        attributionControl: false
      })
      this.bounds = [[0, 0], [map.height, map.width]]
      L.imageOverlay(
        map.mapurl + '&marker=1&type=.png',
        this.bounds
      ).addTo(this.viewer)
      this.zoomBounds()
    }
}