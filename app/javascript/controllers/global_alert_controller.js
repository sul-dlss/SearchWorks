import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="global-alert"
export default class extends Controller {
  static values = { cookieId: String, dismiss: String }

  writeCookie() {
    const cookieId = this.cookieIdValue;
    if (!cookieId) return;

    let lifetime;

    if (this.dismissValue == "permanent") {
      const date = new Date();
      date.setFullYear(date.getFullYear() + 1);
      lifetime = `expires=${date.toUTCString()}`;
    }

    document.cookie = `${cookieId}=dismissed; ${lifetime} path=/; HttpOnly; SameSite=None`;
  }
}
