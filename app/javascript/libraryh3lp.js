import fetchJsonp from "fetch-jsonp";

function libraryH3lp(element) {
  const item = element;
  const link = element.querySelector("a");
  const icon = element.querySelector("span.bi");
  const jid = element.dataset.jid;

  checkStatus();

  function checkStatus() {
    const jidSplit = jid.split("@");
    fetchJsonp(
      `https://libraryh3lp.com/presence/jid/${jidSplit[0]}/${jidSplit[1]}/js`,
      {
        jsonpCallback: "cb",
      })
      .then(() => {
        // The libraryh3lp response sets the jabber_resources at the window level. It doesn't use the callback.
        window["jabber_resources"].forEach((value) => {
          if (value.show === "available") {
            setAsAvailable()
          } else {
            setAsUnavailable()
          }
        })
      })
  }

  function setAsAvailable() {
    icon.classList.remove("bi-chat")
    icon.classList.add("bi-chat-fill")
    link.classList.remove("disabled")
    item.addEventListener("click", handleAvailableClick)
  }

  function setAsUnavailable() {
    icon.classList.remove("bi-chat-fill")
    icon.classList.add("bi-chat")
    link.classList.add("disabled")
    item.removeEventListener("click", handleAvailableClick)
    item.addEventListener("click", handleUnavailableClick)
  }

  function handleAvailableClick(e) {
    e.preventDefault()
    window.open(
      `//libraryh3lp.com/chat/${jid}?skin=16208&sounds=true`,
      "chat",
      "resizable=1,width=420,height=400"
    )
  }

  function handleUnavailableClick(e) {
    e.preventDefault();
    return;
  }
}

function initializeLibraryH3lp() {
  const elements = document.querySelectorAll("[data-library-h3lp]");
  elements.forEach(element => libraryH3lp(element))
}

Blacklight.onLoad(initializeLibraryH3lp);
