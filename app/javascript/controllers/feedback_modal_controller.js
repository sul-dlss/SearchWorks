import { Controller } from "@hotwired/stimulus"
import Blacklight from "blacklight-frontend"

// Connects to data-controller="feedback-modal"
export default class extends Controller {
  closeModal() {
    Blacklight.Modal.hide()
  }
}
