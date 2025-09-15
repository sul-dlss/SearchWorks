import { Controller } from "@hotwired/stimulus"
import L from "leaflet"
import fetchJsonp from 'fetch-jsonp';

export default class extends Controller {
  static values = {
    apiUrl: String
  }

  static targets = ["map", "directions", "directionsTab", "callnumber", "library", "floorname", 'fitButton', 'zoomOutButton']

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

      if (map.directions == "") {
        this.directionsTabTarget.classList.add('d-none')
      } else {
        // Replace <li>- with <li>
        this.directionsTarget.innerHTML = map.directions.replaceAll(/<li>-\s*/g, '<li>')
      }

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
      this.viewer.fitBounds(this.bounds);
      this.fitButtonTarget.classList.add('disabled')
      this.zoomOutButtonTarget.classList.add('disabled')
    }
  }

  /**
   * Update the zoom control state based on the current map state.
   */
  handleBoundsChanged(e) {
    if (!this.viewer || !this.fittedBounds) return;

    if (this.viewer.getZoom() <= this.viewer.getMinZoom()) {
      this.zoomOutButtonTarget.classList.add('disabled')
    } else {
      this.zoomOutButtonTarget.classList.remove('disabled')
    }

    if (this.viewer.getBounds().equals(this.fittedBounds)) {
      this.fitButtonTarget.classList.add('disabled')
    } else {
      this.fitButtonTarget.classList.remove('disabled')
    }
  }

  addOsd() {
    this.viewer = L.map(this.osdId, {
      crs: L.CRS.Simple,
      minZoom: -2,
      zoomControl: false,
      attributionControl: false,
      zoomSnap: 0.5
    })

    L.imageOverlay(
      `${this.mapurl}&marker=1&type=.png`,
      this.bounds
    ).addTo(this.viewer)

    this.zoomBounds()

    // bookkeep the initial viewer bounds
    this.fittedBounds = this.viewer.getBounds();

    // Enable reset button after zoom
    this.viewer.on('zoomstart', () => this.fitButtonTarget.classList.remove('disabled'))
    this.viewer.on('movestart', () => this.fitButtonTarget.classList.remove('disabled'))
    this.viewer.on('moveend', (e) => this.handleBoundsChanged(e))
    this.viewer.on('zoomend', (e) => this.handleBoundsChanged(e))
  }
}
