module RequestLinks
  class HooverRequestLinkComponent < LocationRequestLinkComponent
    def render?
      true
    end

    def link_href
      HooverOpenUrlRequest.new(library, document).to_url
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
