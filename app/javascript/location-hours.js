Blacklight.onLoad(() => {
  document.querySelectorAll('[data-hours-route]').forEach(elem => locationHours(elem))
})

function locationHours(element) {
  const formatTimeRange = ({ openTime, closeTime, isClosed }) => {
    if (isClosed) {
      return "Closed today"
    } else if (openTime === '12a' && closeTime === '11:59p') {
      return "Open 24hr today"
    } else {
      return `Today's hours: ${openTime} - ${closeTime}`
    }
  }

  const parseTime = dateString => {
    const date = new Date(dateString)
    const options = { timeZone: 'America/Los_Angeles', timeStyle: 'short' }
    const shortTime = new Intl.DateTimeFormat('en-US', options).format(date)
    const [time, period] = shortTime.split(' ')
    const formattedTime = time.replace(':00', '')
    const formattedPeriod = period === 'AM' ? 'a' : 'p'
    return formattedTime + formattedPeriod
  }

  const hoursElement = element.querySelector('.location-hours-today')
  const libLocation = element.getAttribute('data-hours-route')

  fetch(libLocation)
    .then(response => response.json())
    .then(data => {
      if (data.error) {
        hoursElement.innerHTML = data.error
        return
      }
      if (data === null) {
        return
      }
      const openTime = parseTime(data[0].opens_at)
      const closeTime = parseTime(data[0].closes_at)
      const isClosed = data[0].closed
      hoursElement.innerHTML = formatTimeRange({ openTime, closeTime, isClosed })
    })
    .catch(error => {
      console.error("Problem getting hours", libLocation, error)
    })
}
