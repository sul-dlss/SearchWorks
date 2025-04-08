# frozen_string_literal: true

module AccessPanels
  class OtherListingsComponent < AccessPanels::Base
    def render?
      document.druid.present?
    end

    def purl_url
      "#{Settings.PURL_EMBED_RESOURCE}#{document.druid}"
    end

    def meta_json_url
      "#{purl_url}.meta_json"
    end

    def earthworks_url
      "#{Settings.earthworks.url}/catalog/stanford-#{document.druid}"
    end
  end
end
