import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    url: String
  }

  connect() {
    fetch(this.liveLookupURL())
      .then((response) => response.json())
      .then((data) => this.handleResponse(data))
      .catch(console.error)
  }

  handleResponse(data) {
    data.forEach((live_data) => {
      const dom_item = document.querySelector(`[data-item-id="${live_data.item_id}"]`)
      if (!dom_item) return;

      const target = dom_item.querySelector(dom_item.dataset.statusTarget)
      const temporary_location = dom_item.querySelector('.temporary-location')
      const status_text = target ? target.nextElementSibling : null
      const update_status = dom_item.dataset.updateStatus

      if (update_status) {
        if (live_data.status && status_text){
          status_text.innerHTML = live_data.status
        }

        // check for due date and if date in temporary location (if the user goes to the page by hitting back).
        if (live_data.due_date && temporary_location && !temporary_location.textContent.includes('Due')) {
          temporary_location.insertAdjacentText('beforeend', `Due ${live_data.due_date}`);
        }
      }

      if (!live_data.is_available && target && (target.classList.contains('unknown') || target.classList.contains('deliver-from-offsite')) ) {
        target.classList.remove('unknown')
        target.classList.remove('deliver-from-offsite')
        target.classList.add('unavailable')
        if (target.hasAttribute('title') && status_text) {
          target.setAttribute('title', status_text.dataset.unavailableText || '')
        }
        if (dom_item.dataset.requestUrl && live_data.is_requestable_status) {
          const link = `<a rel='nofollow' class='btn btn-xs request-button' title='Opens in new tab' target='_blank' href="${dom_item.dataset.requestUrl}">Request <span class='visually-hidden'>(opens in new tab)</span></a>`
          const requestLink = dom_item.querySelector('.request-link')
          if (requestLink) {
            requestLink.innerHTML = link;
          }
        }
      }
      if (live_data.is_available && dom_item && target && target.classList.contains('unknown')) {
        target.classList.remove('unknown');
        target.classList.add('available');
        if (status_text) {
          status_text.textContent = status_text.dataset.availableText || '';
          if (target.hasAttribute('title')) {
            target.setAttribute('title', status_text.dataset.availableText || '');
          }
        }
      }
    })
  }

  liveLookupURL(container) {
    const root_path = this.urlValue
    const ids = this.listOfIds().map((id) => `ids[]=${id}`)
    return `${root_path}?${ids.join('&')}`
  }

  listOfIds() {
    const ids = new Set()
    this.element.querySelectorAll('[data-live-lookup-id]').forEach((elem) => {
      ids.add(elem.dataset.liveLookupId)
    })

    return [...ids]
  }
}
