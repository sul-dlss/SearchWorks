class AccessPanels
  class TemporaryAccess < ::AccessPanel
    def present?
      @document['hathitrust_info_struct'].present? && !fulltext_available?
    end

    def many?
      hathitrust_info.many? || many_holdings?
    end

    # According to https://www.hathitrust.org/hathifiles_description access will be "allow"
    # even in the case that the item is copyrighted in the US, or only Public Domain in the US
    # (and therefore not available to users outside the US).
    def publicly_available?
      hathitrust_info['access'] == 'allow' &&
      !%w[icus pdus].include?(hathitrust_info['rights'])
    end

    def url
      return work_url if many?

      item_url
    end

    # TODO: use criteria to select this item based on contributor,...others?
    def hathitrust_info
      @hathitrust_info ||= JSON.parse(@document['hathitrust_info_struct'].first)
    end

    private

    def work_url
      "https://catalog.hathitrust.org/Record/#{hathitrust_info['ht_bib_key']}"
    end

    def item_url
      "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=urn:mace:incommon:stanford.edu&target=#{URI.encode(item_target(hathitrust_info['htid']))}"
    end

    def many_holdings?
      @document.holdings.callnumbers.many?(&:present?)
    end

    def fulltext_available?
      @document&.index_links&.fulltext&.any? || @document&.index_links&.sfx&.any?
    end

    def item_target(id)
      "https://babel.hathitrust.org/cgi/pt?id=#{URI.encode(id)}&view=1up&seq=9"
    end
  end
end
