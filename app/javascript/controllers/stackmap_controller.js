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


  // Inform Leaflet that the map needs to redraw.
  tabVisibility() {
    this.viewer.invalidateSize()
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

      this.libraryTarget.textContent = map.library
      this.floornameTarget.textContent = map.floorname
      // Replace <li>- with <li>
      this.directionsTarget.innerHTML = map.directions.replaceAll(/<li>-\s*/g, '<li>')

      this.bounds = [[0, 0], [map.height, map.width]]
      this.mapurl = map.mapurl
      this.osdId = `osd-${index}-${Math.floor(Math.random() * 200000000)}`

      const mapClone = this.mapTarget.cloneNode(true)
      // Replace the map target with the cloned one
      this.mapTarget.replaceWith(mapClone)
      const osd = mapClone.querySelector(".osd")
      osd.id = this.osdId
      this.addOsd()

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

  addOsd() {
    this.viewer = L.map(this.osdId, {
      crs: L.CRS.Simple,
      minZoom: -2,
      zoomControl: false,
      attributionControl: false
    })

    L.imageOverlay(
      `${this.mapurl}&marker=1&type=.png`,
      this.bounds
    ).addTo(this.viewer)

    this.zoomBounds()
  }
}
