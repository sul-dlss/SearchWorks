# frozen_string_literal: true

module AccessPanels
  class SfxComponent < AccessPanels::Base
    def sfx_url
      @document.eds_links&.sfx&.first&.href
    end

    def render?
      sfx_url.present?
    end
  end
end
