import { Controller } from "@hotwired/stimulus"
import fetchJsonp from "fetch-jsonp"

export default class extends Controller {
    static targets = [ 'icon', 'link' ]

    static values = {
        jid: String
    }

    connect() {
        this.available = false
        this.checkStatus()
    }
    
    checkStatus() {
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
        this.linkTarget.classList.remove("disabled")
    }

    setAsUnavailable() {
        this.available = false
        this.iconTarget.classList.remove("bi-chat-fill")
        this.iconTarget.classList.add("bi-chat")
        this.linkTarget.classList.add("disabled")
    }

    openChat(event) {
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
    
}