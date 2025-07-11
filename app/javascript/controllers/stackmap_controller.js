import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import fetchJsonp from 'fetch-jsonp';

export default class extends Controller {
  static values = {
    apiUrl: String
  }

  static targets = ["map", "directions", "callnumber", "library", "floorname"]

  connect() {
    fetchJsonp(this.apiUrlValue, { headers: { 'accept': 'application/json' } })
      .then((response) => response.json())
      .then((data) => this.handleResponse(data))
      .catch((error) => {
        console.error("StackMap fetch error:", error)
        this.element.innerHTML = '<p>Error loading map data.</p>'
      })
  }

  handleResponse(data) {
    if (data.stat === "OK" && data.results.maps.length > 0) {
      this.plugContent(data)
    } else {
      this.element.innerHTML = '<p>No map available for this item</p>'
    }
  }

  plugContent(data) {
    const { callno, maps } = data.results

    this.callnumberTarget.textContent = callno

    maps.forEach((map, index) => {
      const mapClone = this.mapTarget.cloneNode(true)
      const zoomControls = mapClone.querySelector(".zoom-controls")

      this.libraryTarget.textContent = map.library
      this.floornameTarget.textContent = map.floorname

      const osd = mapClone.querySelector(".osd")
      osd.id = `osd-${index}`

      // Replace <li>- with <li>
      this.directionsTarget.innerHTML = map.directions.replaceAll(/<li>-\s*/g, '<li>')

      // Replace the map target with the cloned one
      this.mapTarget.replaceWith(mapClone)

      // Render map
      this.addOsd(map, `osd-${index}`, zoomControls)
    })
  }

  zoomIn() {
    this.viewer?.zoomIn()
  }

  zoomOut() {
    this.viewer?.zoomOut()
  }

  zoomBounds() {
    if (this.viewer && this.bounds) {
      this.viewer.fitBounds(this.bounds)
    }
  }

  addOsd(map, osdId) {
    this.viewer = L.map(osdId, {
      crs: L.CRS.Simple,
      minZoom: -2,
      zoomControl: false,
      attributionControl: false
    })

    this.bounds = [[0, 0], [map.height, map.width]]

    L.imageOverlay(
      `${map.mapurl}&marker=1&type=.png`,
      this.bounds
    ).addTo(this.viewer)

    this.zoomBounds()
  }
}
