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
      const temporary_location = $('.temporary-location', dom_item)
      const status_text = target.next('.status-text')
      const update_status = $(dom_item).data('update-status')

      if (update_status) {
        if (live_data.status){
          status_text.html(live_data.status)
        }

        // check for due date and if date in temporary location (if the user goes to the page by hitting back).
        if (live_data.due_date && !temporary_location.text().includes('Due')) {
          temporary_location.append(`Due ${live_data.due_date}`);
        }
      }

      if (!live_data.is_available && (target.hasClass('unknown') || target.hasClass('deliver-from-offsite')) ) {
        target.removeClass('unknown')
        target.removeClass('deliver-from-offsite')
        target.addClass('unavailable')
        if (target.attr('title')) {
          target.attr('title', status_text.data('unavailable-text'))
        }
        if (dom_item.data('request-url') && live_data.is_requestable_status) {
          const link = `<a rel='nofollow' class='btn btn-xs request-button' title='Opens in new tab' target='_blank' href="${dom_item.data('request-url')}">Request <span class='visually-hidden'>(opens in new tab)</span></a>`
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
