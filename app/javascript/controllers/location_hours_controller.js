import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    route: String
  }

  static targets = ["hours"]

  connect() {
    this.locationHours()
  }

  formatTimeRange({ openTime, closeTime, isClosed }) {
    if (isClosed) {
      return "Closed today"
    } else if (openTime === "12a" && closeTime === "11:59p") {
      return "Open 24hr today"
    } else {
      return `Today's hours: ${openTime} - ${closeTime}`
    }
  }

  parseTime(dateString) {
    const date = new Date(dateString)
    const options = { timeZone: "America/Los_Angeles", timeStyle: "short" }
    const shortTime = new Intl.DateTimeFormat("en-US", options).format(date)
    const [time, period] = shortTime.split(" ")
    const formattedTime = time.replace(":00", "")
    const formattedPeriod = period === "AM" ? "a" : "p"
    return formattedTime + formattedPeriod
  }

  updateElement(data) {
    if (data.error) this.hoursTarget.innerHTML = data.error
    if (data.error || data === null) return

    const openTime = this.parseTime(data[0].opens_at)
    const closeTime = this.parseTime(data[0].closes_at)
    const isClosed = data[0].closed
    this.hoursTarget.innerHTML = this.formatTimeRange({ openTime, closeTime, isClosed })
  }

  locationHours() {
    fetch(this.routeValue)
      .then(response => response.json())
      .then(data => this.updateElement(data))
      .catch(error => {
        console.error("Problem getting hours", this.routeValue, error)
      })
  }
}
