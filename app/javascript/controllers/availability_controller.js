import { Controller } from "@hotwired/stimulus"

// search results item availability display
export default class extends Controller {
  static targets = ["location"]

  connect() {
    this.updateLocationColumnsToEqualWidth()
  }
  
  // The length of location labels can vary dramatically. It looks better if the items area aligns for all locations within an instance.
  updateLocationColumnsToEqualWidth(maxWidth = 25, additionalPadding = 5) {
    const bestWidth = Math.min(maxWidth, this.maxLocationColumnWidth());

    this.locationTargets.forEach((location) => {
      if (location.children[0].textContent.trim().length > maxWidth) {
        location.style.width = `${bestWidth + additionalPadding}ch`;
      } else {
        location.style.minWidth = `${bestWidth + additionalPadding}ch`;
      }
    });
  }

  maxLocationColumnWidth() {
    return Math.max(...this.locationTargets.map((location) => { return location.children[0].textContent.trim().length }));
  }
}
