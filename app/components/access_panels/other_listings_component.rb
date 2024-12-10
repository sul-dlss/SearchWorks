# frozen_string_literal: true

module AccessPanels
  class OtherListingsComponent < AccessPanels::Base
    def render?
      earthworks_url.present? || purls.present?
    end

    def earthworks_url
      @earthworks_url ||= construct_earthworks_url
    end

    # @return [Array<String>] a tags representing PURL links
    def purl_links
      @purl_links ||=
        if purls.size > 1 # text of the link is the actual URL if there is more than one unique URL, so there aren't multiple links with the same title
          purls.map { |purl| link_to(purl, purl) }
        elsif purls.size == 1
          Array(link_to('Stanford Digital Repository', purls.first))
        else
          []
        end
    end

    private

    # @return [Array<String>] URLs representing links to PURL, whether specified in MARC or MODS, and de-duped, e.g. ["https://purl.stanford.edu/hj948rn6493"]
    def purls
      @purls ||= (mods_purls + marc_managed_purls).uniq
    end

    # @return [Array<String>] URLs representing links to other locations, extracted from MODS metadata, e.g. ["https://purl.stanford.edu/hj948rn6493"]
    def mods_purls
      Array(document['url_fulltext']).find_all { |str| str.start_with?(Settings.PURL_EMBED_RESOURCE) }
    end

    # @return [Array<String>] URLs representing links to other locations, extracted from MARC metadata, e.g. ["https://purl.stanford.edu/hj948rn6493"]
    def marc_managed_purls
      document.marc_links.managed_purls.filter_map(&:href) # filter_map because href can be nil, at least in fixture data
    end

    def construct_earthworks_url
      return nil unless document['dor_content_type_ssi'] == 'geo'

      # * Hardcoding this simple URL format because it should work for all things it'd apply to (anything released to both SW and EW should be a Stanford object)
      # * Using Kernel.format because there's a clashing ViewComponent::Base#format, so the namespacing is needed
      Kernel.format('https://%<hostname>s/catalog/stanford-%<bare_druid>s', hostname: Settings.earthworks.hostname, bare_druid: document.druid)
    end
  end
end
