import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["challenge", "frame"]
  static values = { challengePath: String, siteKey: String, status: Boolean }

  connect() {
    turnstile.implicitRender()
  }

  frameTargetConnected(element) {
    if (this.statusValue) {
      this.convertFrame(element.querySelector("turbo-frame"))
    } else {
      this.connectChallenge()
    }
  }

  statusValueChanged() {
    if (!this.statusValue) return

    this.frameTargets.forEach(element => {
      this.convertFrame(element.querySelector("turbo-frame"))
    })
  }

  convertFrame(frame) {
    frame.src = atob(frame.src)
    frame.removeAttribute("disabled")
  }

  connectChallenge() {
    if (
      this.statusValue ||
      !this.hasChallengeTarget ||
      this.challengeTarget.childElementCount > 0
    )
      return

    turnstile.render(this.challengeTarget, {
      sitekey: this.siteKeyValue,
      callback: token => this.handleChallengeResponse(token),
      "before-interactive-callback": () => {
        this.challengeTarget.classList.add(
          "alert",
          "alert-info",
          "alert-dismissible",
          "shadow-sm",
          "mt-4",
          "mb-0"
        )
        if (!this.challengeTarget.querySelector("i.bi.bi-info-circle-fill")) {
          const msg = document.createElement("div")
          msg.innerText = "For real-time availability, please verify below."
          msg.classList.add("text-body", "mb-2")
          this.challengeTarget.prepend(msg)
          const icon = document.createElement("i")
          icon.classList.add(
            "bi",
            "bi-info-circle-fill",
            "fs-3",
            "me-3",
            "mt-4",
            "float-start"
          )
          this.challengeTarget.prepend(icon)
        }
      },
      appearance: "interaction-only"
    })
  }

  async handleChallengeResponse(token) {
    const csrfToken = document.querySelector("[name='csrf-token']")

    const response = await fetch(this.challengePathValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken?.content,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ cf_turnstile_response: token })
    })

    const result = await response.json().catch(() => {
      throw new Error(
        `Invalid JSON in response from ${this.challengePathValue}: ${response.statusText}`
      )
    })
    if (result["success"] == true) {
      turnstile.remove()
      this.challengeTarget.className = ""
      this.challengeTarget.innerHTML = ""
      this.statusValue = true
    }
  }
}
