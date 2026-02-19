import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="cocina-view"
export default class extends Controller {
  // Dynamically load highlight.js and register the JSON language, then hightlight the code on the page
  async connect() {
    try {
      const module = await import("https://esm.sh/highlight.js@11.11.1")
      const hljs = module.default

      const json =
        await import("https://esm.sh/highlight.js@11.11.1/lib/languages/json")
      hljs.registerLanguage("json", json.default)

      hljs.highlightAll()
    } catch (error) {
      console.error("Failed to load highlight.js", error)
    }
  }
}
