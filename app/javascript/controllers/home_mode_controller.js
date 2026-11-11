import { Controller } from "@hotwired/stimulus"

// Switches the home page hero between the search form and the chat assistant, sliding one
// pane out as the other slides in. The mode is kept in the URL as ?mode=chat so it survives
// reloads, the login round trip, and Back.
export default class extends Controller {
  static targets = ["tab", "pane", "chatInput"]

  connect() {
    // A Turbo restoration visit brings back the snapshot as it was, so trust the URL instead.
    this.apply(this.modeFromUrl(), { animate: false })
  }

  get mode() {
    return this.element.classList.contains("chat-active") ? "chat" : "search"
  }

  modeFromUrl() {
    return new URL(window.location.href).searchParams.get("mode") === "chat" ? "chat" : "search"
  }

  select(event) {
    this.show(event.currentTarget.dataset.mode)
  }

  // Arrow keys move between tabs, as the ARIA tabs pattern expects.
  keydown(event) {
    if (!["ArrowLeft", "ArrowRight", "Home", "End"].includes(event.key)) return

    event.preventDefault()
    const index = this.tabTargets.indexOf(event.currentTarget)
    const last = this.tabTargets.length - 1
    const next = { ArrowLeft: index - 1, ArrowRight: index + 1, Home: 0, End: last }[event.key]
    const tab = this.tabTargets[(next + this.tabTargets.length) % this.tabTargets.length]
    tab.focus()
    this.show(tab.dataset.mode)
  }

  show(mode) {
    if (mode === this.mode) return

    this.carryText(mode)
    this.updateUrl(mode)
    this.apply(mode, { animate: !window.matchMedia("(prefers-reduced-motion: reduce)").matches })
    this.focusPane(mode)
  }

  apply(mode, { animate }) {
    const incoming = this.pane(mode)
    const outgoing = this.paneTargets.find((pane) => pane !== incoming)
    this.tabTargets.forEach((tab) => {
      const selected = tab.dataset.mode === mode
      tab.setAttribute("aria-selected", String(selected))
      tab.tabIndex = selected ? 0 : -1
    })

    this.finishTransition?.()
    if (!animate || outgoing.hidden) {
      incoming.hidden = false
      outgoing.hidden = true
      this.element.classList.toggle("chat-active", mode === "chat")
      return
    }

    // Chat sits to the right of search, so it enters from the right and search returns from the left.
    const direction = mode === "chat" ? "forward" : "back"
    incoming.hidden = false
    incoming.classList.add(`home-mode-enter-${direction}`)
    outgoing.classList.add(`home-mode-leave-${direction}`)
    // The hero grows before chat slides in, and shrinks only once search is back in place.
    if (mode === "chat") this.element.classList.add("chat-active")

    const onAnimationEnd = (event) => {
      if (event.target === outgoing) finish()
    }
    const finish = () => {
      this.finishTransition = null
      clearTimeout(fallback)
      outgoing.removeEventListener("animationend", onAnimationEnd)
      incoming.classList.remove(`home-mode-enter-${direction}`)
      outgoing.classList.remove(`home-mode-leave-${direction}`)
      outgoing.hidden = true
      this.element.classList.toggle("chat-active", mode === "chat")
    }
    // animationend never fires if the animation is skipped, e.g. in a background tab.
    const fallback = setTimeout(finish, 1000)
    this.finishTransition = finish
    outgoing.addEventListener("animationend", onAnimationEnd)
  }

  disconnect() {
    this.finishTransition?.()
  }

  // Whatever was typed in one mode carries over to the other, so typing before toggling isn't lost.
  carryText(mode) {
    const searchInput = this.searchInput
    const chatInput = this.hasChatInputTarget ? this.chatInputTarget : null
    if (!searchInput || !chatInput) return

    const [from, to] = mode === "chat" ? [searchInput, chatInput] : [chatInput, searchInput]
    if (from.value.trim()) to.value = from.value.trim()
  }

  updateUrl(mode) {
    const url = new URL(window.location.href)
    if (mode === "chat") {
      url.searchParams.set("mode", "chat")
    } else {
      url.searchParams.delete("mode")
    }
    // Keep Turbo's history state so its restoration visits still work.
    window.history.replaceState(window.history.state, "", url)
  }

  focusPane(mode) {
    const pane = this.pane(mode)
    const target = mode === "chat"
      ? pane.querySelector("textarea, .chat-assistant-login a")
      : this.searchInput
    target?.focus({ preventScroll: true })
  }

  pane(mode) {
    return this.paneTargets.find((pane) => pane.dataset.mode === mode)
  }

  get searchInput() {
    return this.pane("search")?.querySelector("input[name='q']")
  }
}
