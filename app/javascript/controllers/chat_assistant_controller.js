import { Controller } from "@hotwired/stimulus"
import DOMPurify from "dompurify"
import { marked } from "marked"

const MARKDOWN_TAGS = [
  "a", "blockquote", "br", "code", "del", "em", "h3", "h4", "h5", "h6", "hr",
  "li", "ol", "p", "pre", "strong", "table", "tbody", "td", "th", "thead", "tr", "ul"
]
// Tool results cite the production site; links are rewritten to whichever host is serving this page.
const CANONICAL_ORIGIN = "https://searchworks.stanford.edu"
const STORAGE_KEY = "searchworks.chat.v1"
const MAX_AVAILABILITY_ITEMS = 5
const STREAM_INTERRUPTED = "The answer stream was interrupted before it finished. Please try again, or ask a narrower question."

class LoginRequiredError extends Error {}

// The AI chat assistant (ChatPanelComponent). Each turn POSTs the whole transcript to ChatsController
// and reads its server-sent events. The transcript is kept in sessionStorage, so following a record
// link and coming Back returns to the conversation; nothing is stored on the server.
export default class extends Controller {
  static targets = ["transcript", "intro", "form", "input", "submit", "submitLabel", "error", "login", "reset"]
  static values = { url: String, loginUrl: String }

  connect() {
    this.turns = this.restore()
    this.renderTranscript()
  }

  disconnect() {
    this.abortController?.abort()
  }

  // Turns are { role, content } plus, for answers, the tool calls, sources, and availability shown with them.
  restore() {
    try {
      const turns = JSON.parse(window.sessionStorage.getItem(STORAGE_KEY) || "[]")
      return Array.isArray(turns) ? turns.filter((turn) => turn?.role && typeof turn.content === "string") : []
    } catch {
      return []
    }
  }

  persist() {
    try {
      window.sessionStorage.setItem(STORAGE_KEY, JSON.stringify(this.turns))
    } catch {
      // Storage can be full or blocked; the conversation still works for this page view.
    }
  }

  reset() {
    this.abortController?.abort()
    this.turns = []
    this.persist()
    this.hideError()
    this.renderTranscript()
    if (this.hasInputTarget) this.inputTarget.focus()
  }

  renderTranscript() {
    this.transcriptTarget.querySelectorAll(".chat-message").forEach((message) => message.remove())
    this.turns.forEach((turn) => {
      if (turn.role === "user") {
        this.appendMessage("You", turn.content, "user")
      } else {
        const message = this.appendMessage("Assistant", "", "assistant")
        this.renderAnswer(message, turn)
      }
    })
    this.updateChrome()
    this.scrollToBottom()
  }

  updateChrome() {
    const started = this.turns.length > 0
    if (this.hasIntroTarget) this.introTarget.hidden = started
    if (this.hasResetTarget) this.resetTarget.hidden = !started
  }

  ask({ params: { question } }) {
    if (!this.hasInputTarget || !question) return

    this.inputTarget.value = question
    this.formTarget.requestSubmit()
  }

  keydown(event) {
    if (event.key === "Enter" && !event.shiftKey && !event.isComposing) {
      event.preventDefault()
      this.formTarget.requestSubmit()
    }
  }

  async submit(event) {
    event.preventDefault()
    const content = this.inputTarget.value.trim()
    if (!content || this.busy) return

    this.hideError()
    const question = { role: "user", content }
    this.turns.push(question)
    const userMessage = this.appendMessage("You", content, "user")
    this.inputTarget.value = ""
    this.updateChrome()
    this.setBusy(true)

    const message = this.appendMessage("Assistant", "", "assistant")
    const answer = { role: "assistant", content: "", sources: [], availability: [], toolCalls: [] }
    const status = this.showPlaceholder(message)
    this.scrollToBottom()

    try {
      await this.streamAnswer(message, answer, status)
      if (!answer.content) throw new Error("The assistant did not return an answer. Please try again.")

      this.turns.push(answer)
      this.persist()
      this.renderAnswer(message, answer)
    } catch(error) {
      if (error.name === "AbortError") return

      message.remove()
      userMessage.remove()
      this.turns.splice(this.turns.indexOf(question), 1)
      this.inputTarget.value = content
      if (error instanceof LoginRequiredError) {
        this.loginTarget.hidden = false
      } else {
        this.showError(error.message)
      }
      this.updateChrome()
    } finally {
      this.setBusy(false)
    }
  }

  async streamAnswer(message, answer, status) {
    this.abortController = new AbortController()
    const response = await fetch(this.urlValue, {
      method: "POST",
      signal: this.abortController.signal,
      headers: {
        "Accept": "text/event-stream",
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
      },
      body: JSON.stringify({ messages: this.history() })
    })

    // A session that expired since the page loaded; the transcript stays for after login.
    if (response.status === 401) throw new LoginRequiredError()
    if (response.status === 429) throw new Error("You've sent a lot of questions in a short time. Please wait a few minutes and try again.")
    if (!response.ok) {
      const data = await response.json().catch(() => ({}))
      throw new Error(data.error || "The assistant could not be reached. Please try again.")
    }
    if (!response.body) throw new Error("Streaming is not supported by this browser.")

    const content = message.querySelector(".chat-message-content")
    await this.consumeStream(response.body, (type, data) => {
      if (type === "delta") {
        answer.content += data.content
        this.renderMarkdown(content, answer.content, answer)
      } else if (type === "reset") {
        answer.content = ""
        content.replaceChildren(status.closest(".chat-placeholder"))
      } else if (type === "status") {
        status.textContent = data.message
      } else if (type === "sources") {
        answer.sources = Array.isArray(data.sources) ? data.sources : []
        this.renderMarkdown(content, answer.content, answer)
      } else if (type === "availability") {
        answer.availability.push(data)
        this.renderAvailability(message, answer)
      } else if (type === "notice") {
        answer.notices = [...(answer.notices || []), data.message]
      } else if (type === "tool_call") {
        answer.toolCalls.push({ name: data.name, arguments: data.arguments, result: data.result })
        this.renderToolCalls(message, answer)
        status.textContent = "Reviewing what was found…"
      } else if (type === "error") {
        throw new Error(data.message)
      }
      this.scrollToBottom()
    })
  }

  // Only the role and text of each turn go back to the server.
  history() {
    return this.turns.map(({ role, content }) => ({ role, content }))
  }

  async consumeStream(body, callback) {
    const reader = body.getReader()
    const decoder = new TextDecoder()
    let buffer = ""
    let eventName = "message"
    let dataLines = []
    let completed = false

    const processLine = (line) => {
      if (line === "") {
        if (dataLines.length > 0) {
          if (eventName === "done") completed = true
          callback(eventName, JSON.parse(dataLines.join("\n")))
        }
        eventName = "message"
        dataLines = []
      } else if (line.startsWith("event:")) {
        eventName = line.slice(6).trim()
      } else if (line.startsWith("data:")) {
        dataLines.push(line.slice(5).trimStart())
      }
    }

    try {
      while (true) {
        const { value, done } = await reader.read()
        buffer += decoder.decode(value || new Uint8Array(), { stream: !done })
        const lines = buffer.split(/\r?\n/)
        buffer = lines.pop()
        lines.forEach(processLine)
        if (done) break
      }
    } catch(error) {
      if (error.name === "AbortError") throw error
      console.error("Chat response stream interrupted:", error)
      throw new Error(STREAM_INTERRUPTED)
    }
    if (buffer) processLine(buffer)
    processLine("")
    if (!completed) throw new Error(STREAM_INTERRUPTED)
  }

  appendMessage(label, content, role) {
    const article = document.createElement("article")
    article.className = `chat-message chat-message-${role}`

    const heading = document.createElement("div")
    heading.className = "chat-message-label"
    heading.textContent = label

    const body = document.createElement("div")
    body.className = "chat-message-content"
    body.textContent = content

    article.append(heading, body)
    this.transcriptTarget.append(article)
    return article
  }

  // @return [HTMLElement] the status line, updated as tools run
  showPlaceholder(message) {
    const placeholder = document.createElement("div")
    placeholder.className = "chat-placeholder placeholder-glow"
    for (const width of ["col-12", "col-9", "col-6"]) {
      const bar = document.createElement("span")
      bar.className = `placeholder ${width}`
      bar.setAttribute("aria-hidden", "true")
      placeholder.append(bar)
    }
    const status = document.createElement("div")
    status.className = "chat-status text-body-secondary small mt-1"
    status.textContent = "Thinking…"
    placeholder.append(status)
    message.querySelector(".chat-message-content").append(placeholder)
    return status
  }

  renderAnswer(message, answer) {
    this.renderToolCalls(message, answer)
    this.renderMarkdown(message.querySelector(".chat-message-content"), answer.content, answer)
    this.renderAvailability(message, answer)
    message.querySelectorAll(".chat-notice").forEach((notice) => notice.remove())
    ;(answer.notices || []).forEach((text) => {
      const notice = document.createElement("div")
      notice.className = "chat-notice alert alert-warning small py-2 mt-2 mb-0"
      notice.textContent = text
      message.append(notice)
    })
  }

  // Links survive only when they point at a record, request page, or online source a tool returned;
  // anything else the model wrote becomes plain text.
  renderMarkdown(container, text, answer) {
    if (!text) return

    const verified = this.verifiedUrls(answer)
    const html = DOMPurify.sanitize(marked.parse(text, { breaks: true, gfm: true }), {
      ALLOWED_TAGS: MARKDOWN_TAGS,
      ALLOWED_ATTR: ["href"]
    })
    const template = document.createElement("template")
    template.innerHTML = html
    template.content.querySelectorAll("a").forEach((link) => {
      const href = link.getAttribute("href")
      if (verified.has(href)) {
        link.setAttribute("href", this.localUrl(href))
      } else {
        link.replaceWith(document.createTextNode(link.textContent))
      }
    })
    template.content.querySelectorAll("table").forEach((table) => {
      table.classList.add("table", "table-sm")
      const wrapper = document.createElement("div")
      wrapper.className = "table-responsive"
      table.replaceWith(wrapper)
      wrapper.append(table)
    })
    container.replaceChildren(template.content)
  }

  verifiedUrls(answer) {
    const urls = new Set((answer.sources || []).map((source) => source.url))
    ;(answer.availability || []).forEach((record) => {
      urls.add(record.url)
      ;(record.availability || []).forEach((item) => item.request_url && urls.add(item.request_url))
      ;(record.online_sources || []).forEach((source) => urls.add(source.url))
    })
    urls.delete(undefined)
    return urls
  }

  localUrl(url) {
    if (!url?.startsWith(`${CANONICAL_ORIGIN}/`) || window.location.origin === CANONICAL_ORIGIN) return url

    return url.slice(CANONICAL_ORIGIN.length)
  }

  safeUrl(url) {
    try {
      return ["http:", "https:"].includes(new URL(url, document.baseURI).protocol) ? url : null
    } catch {
      return null
    }
  }

  // Each tool the assistant used, collapsed to its name, with the request and response inside.
  renderToolCalls(message, answer) {
    message.querySelector(".chat-tool-calls")?.remove()
    const calls = answer.toolCalls || []
    if (calls.length === 0) return

    const list = document.createElement("div")
    list.className = "chat-tool-calls"
    calls.forEach((call) => {
      const details = document.createElement("details")
      details.className = "chat-tool-call"
      const summary = document.createElement("summary")
      const name = document.createElement("code")
      name.textContent = call.name
      summary.append(name)
      details.append(
        summary,
        this.toolCallSection("Request", this.prettyJson(call.arguments)),
        this.toolCallSection("Response", call.result)
      )
      list.append(details)
    })
    message.querySelector(".chat-message-content").before(list)
  }

  toolCallSection(label, text) {
    const section = document.createElement("div")
    section.className = "chat-tool-call-section"
    const heading = document.createElement("div")
    heading.className = "chat-tool-call-label"
    heading.textContent = label
    const body = document.createElement("pre")
    body.textContent = text || ""
    section.append(heading, body)
    return section
  }

  // The model sends arguments as a JSON string; show them indented, or as sent if they don't parse.
  prettyJson(text) {
    try {
      return JSON.stringify(JSON.parse(text || "{}"), null, 2)
    } catch {
      return text
    }
  }

  renderAvailability(message, answer) {
    message.querySelector(".chat-availability-list")?.remove()
    const records = this.uniqueRecords(answer.availability || [])
    if (records.length === 0) return

    const list = document.createElement("div")
    list.className = "chat-availability-list"
    records.forEach((record) => list.append(this.availabilityCard(record)))
    message.querySelector(".chat-message-content").after(list)
  }

  // The model sometimes checks the same record twice; show the latest result once.
  uniqueRecords(records) {
    const byId = new Map()
    records.forEach((record) => byId.set(record.id, record))
    return Array.from(byId.values())
  }

  availabilityCard(record) {
    const card = document.createElement("div")
    card.className = "chat-availability card"
    const body = document.createElement("div")
    body.className = "card-body"
    card.append(body)

    const title = document.createElement("div")
    title.className = "chat-availability-title"
    const link = this.anchor(record.url, record.title || `Catalog record ${record.id}`)
    title.append(link || document.createTextNode(record.title || record.id))
    body.append(title)

    const items = record.availability || []
    if (record.too_many_items) {
      body.append(this.textLine(`${record.item_count} items, such as individual volumes. Open the record to check a specific one.`))
    } else if (items.length > 0) {
      const list = document.createElement("ul")
      list.className = "list-unstyled mb-0"
      items.slice(0, MAX_AVAILABILITY_ITEMS).forEach((item) => list.append(this.availabilityItem(item)))
      body.append(list)
      if (items.length > MAX_AVAILABILITY_ITEMS) {
        body.append(this.textLine(`${items.length - MAX_AVAILABILITY_ITEMS} more items; open the record to see them all.`))
      }
    }

    const online = (record.online_sources || []).map((source) => {
      const label = `${source.label || "Online access"}${source.stanford_only ? " (Stanford only)" : ""}`
      return this.anchor(source.url, label)
    }).filter(Boolean)
    if (online.length > 0) {
      const line = this.textLine("Online: ")
      online.forEach((anchor, index) => {
        if (index > 0) line.append(", ")
        line.append(anchor)
      })
      body.append(line)
    }
    if (record.live_status === false && items.length > 0 && !record.too_many_items) {
      body.append(this.textLine("Current status could not be retrieved; statuses may be out of date.", "text-body-secondary"))
    }
    return card
  }

  availabilityItem(item) {
    const row = document.createElement("li")
    row.className = "chat-availability-item"

    const status = document.createElement("span")
    status.className = `badge ${item.is_available ? "text-bg-success" : "text-bg-secondary"}`
    status.textContent = item.status || "Unknown"
    row.append(status)

    const where = [item.library, item.location].filter(Boolean).filter((value, index, all) => all.indexOf(value) === index)
    const details = document.createElement("span")
    details.className = "chat-availability-details"
    details.textContent = where.join(" — ")
    if (item.call_number) {
      const callNumber = document.createElement("span")
      callNumber.className = "chat-availability-callnumber"
      callNumber.textContent = item.call_number
      details.append(callNumber)
    }
    if (item.due_date) details.append(` (due ${item.due_date})`)
    row.append(details)

    const request = this.anchor(item.request_url, "Request")
    if (request) {
      request.className = "btn btn-sm btn-outline-primary chat-availability-request"
      row.append(request)
    }
    return row
  }

  anchor(url, text) {
    if (!url || !this.safeUrl(url)) return null

    const link = document.createElement("a")
    link.href = this.localUrl(url)
    link.textContent = text
    return link
  }

  textLine(text, extraClass = "") {
    const line = document.createElement("div")
    line.className = `small mt-1 ${extraClass}`.trim()
    line.textContent = text
    return line
  }

  scrollToBottom() {
    this.transcriptTarget.scrollTop = this.transcriptTarget.scrollHeight
  }

  setBusy(busy) {
    this.busy = busy
    this.submitTarget.disabled = busy
    this.submitLabelTarget.textContent = busy ? "Searching…" : "Send"
    this.transcriptTarget.setAttribute("aria-busy", String(busy))
  }

  showError(message) {
    this.errorTarget.textContent = message
    this.errorTarget.hidden = false
  }

  hideError() {
    this.errorTarget.hidden = true
    this.errorTarget.textContent = ""
  }
}
