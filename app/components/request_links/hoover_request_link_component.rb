# frozen_string_literal: true

module RequestLinks
  class HooverRequestLinkComponent < LocationRequestLinkComponent
    delegate :items, to: :location

    def render?
      items.any? do |item|
        item.effective_location&.details&.dig('availabilityClass') != 'In_process_non_requestable'
      end
    end

    def link_text
      return I18n.t('searchworks.request_link.finding_aid') if has_finding_aid?

      I18n.t('searchworks.request_link.aeon')
    end

    def link_href
      return document&.access_panel_links&.finding_aid&.first&.href if has_finding_aid?

      HooverOpenUrlRequest.new(library_code, document).to_url
    end

    def link_params
      @link_params.merge(data: @link_params.fetch(:data, {}).reverse_merge(
        toggle: 'tooltip',
        html: 'true',
        title: I18n.t('searchworks.request_link.aeon_note')
      ))
    end
  end
end
