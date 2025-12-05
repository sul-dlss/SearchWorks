import { Controller } from "@hotwired/stimulus"
import fetchJsonp from "fetch-jsonp"

// Connects to data-controller="google-cover-image"
export default class extends Controller {
  static targets = ["image"]

  static values = {
    batchSize: { type: Number, default: 15 },
    booksApiUrl: { type: String, default: "https://books.google.com/books?jscmd=viewapi&bibkeys=" }
  }

  connect() {
  }

  imageTargetConnected(_element) {
    const pendingCovers = Array.from(this.imageTargets).filter(el => !el.hasAttribute("busy") && !el.hasAttribute("complete"))
    pendingCovers.forEach(el => { el.setAttribute("busy", "") })

    const batches = []

    if (pendingCovers.length === 0) return

    // batch by batch-cutoff value
    while (pendingCovers.length) {
      batches.push(pendingCovers.splice(0, this.batchSizeValue))
    }

    this.addBookCoversByBatch(batches)
  }

  addBookCoversByBatch(batches) {
    batches.forEach((batch) => {
      const batchBooksApiUrl = this.booksApiUrlValue + this.getBibKeysForBatch(batch)

      fetchJsonp(batchBooksApiUrl)
        .then((response) => response.json())
        .then((json) => this.renderCoverAndAccessPanel(json))
        .catch((e) => console.error(e))
    })
  }

  renderCoverAndAccessPanel(json) {
    // Loop through all the relevant cover elements and if the cover
    // element has a standard number (order of precidence: OCLC, LCCN, then ISBN)
    // that exists in the json response and render the cover image for it.
    this.imageTargets.forEach((coverImg) => {
      coverImg.setAttribute("complete", "")
      coverImg.removeAttribute("busy")

      const data = this.bestResponseForNumber(json, coverImg)
      if (typeof data !== "undefined") {
        this.renderCoverImage(data.bibkey, data.data)
        this.renderAccessPanel(data.bibkey, data.data)
      }
    })
  }

  bestResponseForNumber(json, coverImg) {
    let data
    const oclcKeys = coverImg.dataset.oclc.split(",")
    const lccnKeys = coverImg.dataset.lccn.split(",")
    const isbnKeys = coverImg.dataset.isbn.split(",")
    oclcKeys.forEach((oclc) => {
      if (json[oclc] && typeof json[oclc].thumbnail_url !== "undefined") {
        data = { bibkey: oclc, data: json[oclc] }
        return
      }
    })
    if (typeof data === "undefined") {
      lccnKeys.forEach((lccn) => {
        if (json[lccn] && typeof json[lccn].thumbnail_url !== "undefined") {
          data = { bibkey: lccn, data: json[lccn] }
          return
        }
      })
    }
    if (typeof data === "undefined") {
      isbnKeys.forEach((isbn) => {
        if (json[isbn] && typeof json[isbn].thumbnail_url !== "undefined") {
          data = { bibkey: isbn, data: json[isbn] }
          return
        }
      })
    }
    return data
  }

  renderCoverImage(bibkey, data) {
    if (typeof data.thumbnail_url !== "undefined") {
      let thumbUrl = data.thumbnail_url
      const selectorCoverImg = `img.${bibkey}`

      thumbUrl = thumbUrl.replace(/zoom=5/, "zoom=1")
      thumbUrl = thumbUrl.replace(/&?edge=curl/, "")

      const imageEls = Array.from(this.element.querySelectorAll(selectorCoverImg))


      imageEls.forEach((imageEl) => {
        // Only set the thumb src if it's not already set
        if (imageEl.src === "") {
          imageEl.src = thumbUrl
          imageEl.hidden = false

          const fakeCover = imageEl.parentElement.querySelector("span.fake-cover")
          if (fakeCover) {
            fakeCover.hidden = true
          }
        }
      })
    }
  }

  renderAccessPanel(bibkey, data) {
    if (typeof data.info_url == "undefined" || !["full", "partial", "noview"].includes(data.preview)) return

    const listGoogleBooks = this.element.querySelectorAll(`.google-books.${bibkey}`)

    const labels = {
      full: "Full view",
      partial: "Limited preview",
      noview: "Limited preview"
    }

    listGoogleBooks.forEach((googleBooks) => {
      if (googleBooks.querySelector("a")) return

      const link = document.createElement("a")
      link.href = data.preview_url
      link.innerHTML = `(${labels[data.preview]})`

      googleBooks.appendChild(link)

      this.checkAndEnableAccessPanel(googleBooks, ".access-panel")
    })
  }

  // Return a comma delimited string of identifiers
  getBibKeysForBatch(batch) {
    return batch.flatMap((coverImg) => {
      const isbn = coverImg.dataset.isbn.split(",")
      const oclc = coverImg.dataset.oclc.split(",")
      const lccn = coverImg.dataset.lccn.split(",")

      return isbn.concat(oclc).concat(lccn)
    }).filter(elm => elm).join(",")
  }

  checkAndEnableAccessPanel(googleBooks, panelSelector) {
    const accessPanel = googleBooks.closest(panelSelector)

    if (!accessPanel)
      return

    accessPanel.hidden = false
    googleBooks.hidden = false
  }
}
