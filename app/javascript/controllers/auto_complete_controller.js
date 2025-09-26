import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["autoComplete", "popup", "select"]

  connect() {
    // Check if author has already been selected as search field.
    // If author has been selected, ensure autocomplete source is set correctly
    if (this.selectTarget.value == 'search_author') {
      this.autoCompleteTarget.src = this.autoCompleteTarget.dataset['autoCompleteSrc']
    }
  }
 
  onChange(event) {
    const selectedValue = event.target.value;
    if (selectedValue == 'search_author') {
      this.autoCompleteTarget.src = this.autoCompleteTarget.dataset['autoCompleteSrc']
    } else {
      this.autoCompleteTarget.removeAttribute("src")
      this.popupTarget.setAttribute("hidden", "")
    }
  }
}
