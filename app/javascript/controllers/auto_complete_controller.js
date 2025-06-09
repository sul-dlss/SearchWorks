import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["autoComplete", "popup"]
 
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
