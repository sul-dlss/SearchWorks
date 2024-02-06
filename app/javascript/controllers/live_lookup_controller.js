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
      const dom_item = $(`[data-item-id="${live_data.item_id}"]`)
      const target = $(dom_item.data('status-target'), dom_item)
      const current_location = $('.current-location', dom_item)
      const status_text = target.next('.status-text')

      if (live_data.status) {
        current_location.html(live_data.status);
      }
      if (live_data.due_date) {
        current_location.append(` Due ${live_data.due_date}`);
      }

      if (!live_data.is_available && (target.hasClass('unknown') || target.hasClass('deliver-from-offsite')) ) {
        target.removeClass('unknown')
        target.removeClass('deliver-from-offsite')
        target.addClass('unavailable')
        status_text.text(''); // The due date/current location acts as the status text at this point
        if (target.attr('title')) {
          target.attr('title', status_text.data('unavailable-text'))
        }
        if (dom_item.data('request-url') && live_data.is_requestable_status) {
          const link = `<a rel='nofollow' class='btn btn-xs request-button' title='Opens in new tab' target='_blank' href="${dom_item.data('request-url')}">Request <span class='sr-only'>(opens in new tab)</span></a>`
          $('.request-link', dom_item).html(link);
        }
      }
      if (live_data.is_available && dom_item.length > 0  && target.hasClass('unknown')) {
        target.removeClass('unknown');
        target.addClass('available');
        status_text.text(status_text.data('available-text'));
        if (target.attr('title')) {
          target.attr('title', status_text.data('available-text'));
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
