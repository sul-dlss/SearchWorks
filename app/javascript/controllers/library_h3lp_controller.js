import { Controller } from "@hotwired/stimulus"
import fetchJsonp from "fetch-jsonp"

export default class extends Controller {
    static targets = [ 'icon', 'link', 'placeholder', 'hours' ]

    static values = {
        jid: String,
        hoursUrl: String
    }

    connect() {
        this.available = false
        this.checkStatus()
        this.fetchHours()
    }
    
    checkStatus() {
        if (!this.jidValue) return;

        const jidSplit = this.jidValue.split("@");
        fetchJsonp(
            `https://libraryh3lp.com/presence/jid/${jidSplit[0]}/${jidSplit[1]}/js`,
            { jsonpCallback: "cb",})
            .then(() => {
                // The libraryh3lp response sets the jabber_resources at the window level. It doesn't use the callback.
                window["jabber_resources"].forEach((value) => {
                    if (value.show === "available") {
                        this.setAsAvailable()
                    } else {
                        this.setAsUnavailable()
                    }
                })
            })
    }

    // Set as available
    setAsAvailable() {
        this.available = true
        this.iconTarget.classList.remove("bi-chat")
        this.iconTarget.classList.add("bi-chat-fill")
        this.placeholderTarget.classList.add("d-none")
        this.linkTarget.classList.remove("d-none")
    }

    setAsUnavailable() {
        this.available = false
        this.iconTarget.classList.remove("bi-chat-fill")
        this.iconTarget.classList.add("bi-chat")
        this.linkTarget.classList.add("d-none")
        this.placeholderTarget.classList.remove("d-none")
    }

    openChat(event) {
        if (!this.jidValue) return;

        // Don't navigate to the link
        event.preventDefault();
        // Only allow for opening the window if the click is available
        if(this.available) {
            window.open(
                `//libraryh3lp.com/chat/${this.jidValue}?skin=16208&sounds=true`,
                "chat",
                "resizable=1,width=420,height=400"
              )
        }
    }

    fetchHours() {
        fetch(this.hoursUrlValue)
        .then((response) => response.json())
        .then((data) => this.handleHoursResponse(data))
        .catch(console.error)
    }

    handleHoursResponse(data) {
        const opens = new Date(Date.parse(data[0].opens_at))
        const closes = new Date(Date.parse(data[0].closes_at))
        const now = Date.now()
        if (now > opens && now < closes)
            this.displayOpen(closes)
        else
            this.displayClosed(opens)
    }

    displayClosed(date) {
        this.hoursTarget.innerHTML = `${this.circle('closed')} Closed until ${this.formatHours(date)}`
    }

    displayOpen(date) {
        this.hoursTarget.innerHTML = `${this.circle('open')} Open until ${this.formatHours(date)}`
    }

    circle(status) {
        return `<span class="bi bi-circle-fill open-indicator ${status}"></span>`
    }

    formatHours(date) {
        return date.toLocaleTimeString("en-US", { hour: 'numeric'})
    }
}
