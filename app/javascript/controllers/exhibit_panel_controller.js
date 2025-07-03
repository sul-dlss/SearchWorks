import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="exhibit-panel"
export default class extends Controller {
  static targets = ["exhibit", "cardBody", "title"]
  static values = {
    druid: String,
    exhibitsHost: String,
    isCollection: Boolean,
    headingSingle: String,
    headingMultiple: String
  }

  exhibitToggleThreshold = 5

  connect() {
    if (this.exhibitTargets.length === 0) {
      this.fetchExhibits()
    } else {
      this.addToggleButtonBehavior()
    }
  }

  async fetchExhibits() {
    try {
      const response = await fetch(`${this.exhibitsHostValue}/exhibit_finder/${this.druidValue}`)
      const data = await response.json()

      if (data.length === 0) {
        return
      }

      this.showAppropriatePanelHeading(data.length)

      data.forEach(exhibit => {
        this.createExhibitMediaObject(exhibit, this.cardBodyTarget)
      })

      this.addToggleButtonBehavior()

      const contextHeading = document.querySelector('[data-behavior="metadata-panel-context-heading"]')
      if (contextHeading) {
        contextHeading.style.display = 'block'
      }

      this.element.style.display = 'block'
    } catch (error) {
      console.error('Failed to fetch exhibits:', error)
    }
  }

  exhibitsUrl(slug) {
    const baseExhibitUrl = `${this.exhibitsHostValue}/${slug}`
    if (this.isCollectionValue) {
      return baseExhibitUrl
    } else {
      return `${baseExhibitUrl}/catalog/${this.druidValue}`
    }
  }

  showAppropriatePanelHeading(exhibitCount) {
    this.titleTarget.innerText = exhibitCount > 1 ? this.headingMultipleValue : this.headingSingleValue
  }

  addToggleButtonBehavior() {
    const exhibitElements = this.exhibitTargets
    const exhibitCount = exhibitElements.length
    console.log("count", exhibitCount, "threshold", this.exhibitToggleThreshold)

    if (exhibitCount > this.exhibitToggleThreshold) {
      let toggleButton = this.cardBodyTarget.querySelector('button.see-all-exhibits')

      if (!toggleButton) {
        toggleButton = document.createElement('button')
        toggleButton.className = 'see-all-exhibits btn btn-secondary btn-xs'
        toggleButton.textContent = `show all ${exhibitCount} exhibits`
        toggleButton.addEventListener('click', this.toggleExhibits.bind(this))
        this.cardBodyTarget.appendChild(toggleButton)
      }

      exhibitElements.forEach((element, i) => {
        if (i >= this.exhibitToggleThreshold) {
          element.classList.remove('d-flex')
          element.hidden = true
        }
      })
    }
  }

  toggleExhibits(event) {
    event.preventDefault()

    const toggleButton = event.target
    const exhibitElements = this.exhibitTargets

    // Remove button since we don't have good text for toggle off
    toggleButton.remove()

    exhibitElements.forEach((element, i) => {
      if (i >= this.exhibitToggleThreshold) {
        if (!element.hidden) {
          element.classList.remove('d-flex')
          element.hidden = true
        } else {
          element.classList.add('d-flex')
          element.hidden = false
        }
      }
    })
  }

  createExhibitMediaObject(exhibit, parentNode) {
    const exhibitUrl = this.exhibitsUrl(exhibit.slug)
    const wrapper = document.createElement('div')
    wrapper.dataset.exhibitPanelTarget = 'exhibit'
    wrapper.className = 'd-flex mb-2'
    const subtitle = exhibit.subtitle || ''
    const body = `<div><div class="exhibit-heading"><h4><a href="${exhibitUrl}">${exhibit.title}</a></h4>${subtitle}</div></div>`

    if (exhibit.thumbnail_url) {
      wrapper.innerHTML = `<a href="${exhibitUrl}" tabindex="-1" aria-hidden="true">
        <img alt="" src="${exhibit.thumbnail_url}" class="me-3" />
      </a>${body}`
    } else {
      wrapper.innerHTML = body
    }

    // Add click tracking to exhibit links
    wrapper.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => {
        if (typeof ga !== 'undefined') {
          ga('send', 'event', 'Exhibit link', 'clicked', [exhibit.title, exhibit.subtitle].join(' '), {
            'transport': 'beacon'
          })
        }
      })
    })

    parentNode.appendChild(wrapper)
  }
}