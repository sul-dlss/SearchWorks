import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="long-table"
// This hides rows after the first 5.
export default class extends Controller {
  static values = {
    buttonContext: { type: String, default: "in location" },
    expanded: Boolean,
    rows: { type: Number, default: 5 }
  }

  static targets = [ "body", "button", "notice" ]

  connect() {
    if (!this.children) return;
    if (this.children.length <= this.rowsValue) return;

    if (!this.hasButtonTarget) this.addControls();
    this.collapse()
  }

  get children() {
    if (this.hasBodyTarget) {
      return this.bodyTargets.flatMap((bodyTarget) => Array.from(bodyTarget.children))
    } else {
      return Array.from(this.element.children);
    }
  }

  expand() {
    const firstHiddenElement= this.children.find((childElement) => childElement.hidden);
    this.children.forEach((childElement) => childElement.hidden = false);
    this.expandedValue = true;
    firstHiddenElement.tabIndex = -1;
    firstHiddenElement.focus();
  }

  collapse() {
    Array.from(this.children).forEach((childElement, index) => {
      childElement.hidden = (index >= this.rowsValue) && childElement.dataset.longTablePreserve !== "true";
    })
    this.expandedValue = false;
  }

  toggle() {
    if (this.expandedValue) {
      this.collapse()
      this.buttonTarget.innerText = "show all"
      this.noticeTarget.innerText = `Revealed ${this.children.length - this.rowsValue} items`
    } else {
      this.expand()
      this.buttonTarget.innerText = "show less"
      this.noticeTarget.innerText = `Hidden ${this.children.length - this.rowsValue} items`
    }

    if (this.buttonContextValue) {
      const srSpan = document.createElement("span");
      srSpan.classList.add("visually-hidden");
      srSpan.innerText = this.buttonContextValue;

      this.buttonTarget.appendChild(srSpan);
    }
  }

  addControls() {
    const button = document.createElement("button")
    button.classList.add("btn", "btn-secondary", "btn-xs")
    button.dataset.longTableTarget = "button";
    button.dataset.action = "long-table#toggle";
    button.innerText = this.expandedValue ? "show less" : "show all"

    if (this.buttonContextValue) {
      const srSpan = document.createElement("span");
      srSpan.classList.add("visually-hidden");
      srSpan.innerText = this.buttonContextValue;

      button.appendChild(srSpan);
    }

    if (this.element.tagName === "TABLE") {
      const tbody = document.createElement("tbody")
      const tr = document.createElement("tr")
      const td = document.createElement("td")
      td.setAttribute("colspan", this.children[0].children.length)
      td.appendChild(this.buildNotice());
      td.appendChild(button)
      tr.appendChild(td)
      tbody.appendChild(tr)
      this.element.appendChild(tbody)
    } else if (this.element.tagName === "UL" || this.element.tagName === "OL") {
      const li = document.createElement("li")
      li.dataset.longTablePreserve = "true";
      li.appendChild(this.buildNotice());
      li.appendChild(button)
      this.element.appendChild(li);
    }
  }

  buildNotice() {
    const notice = document.createElement("span");
    notice.classList.add("visually-hidden");
    notice.ariaAtomic = "true";
    notice.ariaLive = "polite";
    notice.profile = "status";
    notice.dataset.longTableTarget = "notice";

    notice.innerText = `showing ${this.rowsValue} of ${this.children.length} items`
    return notice;
  }
}
