import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="record-print"
export default class extends Controller {
  connect() {
  }

  print() {
    if(window.print) window.print()
  }

  cleanup() {
  }
}
