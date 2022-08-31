class HathiTrustLinks
  attr_reader :document
  def initialize(document)
    @document = document
  end

  def present?
    (hathitrust_work_id.present? || hathitrust_item_id.present?) && !fulltext_available?
  end

  # According to https://www.hathitrust.org/hathifiles_description access will be "allow"
  # even in the case that the item is copyrighted in the US, or only Public Domain in the US
  # (and therefore not available to users outside the US).
  def publicly_available?
    return false unless access_rights.present?

    access_rights.none? do |value|
      value == 'deny' || %w[allow:icus allow:pdus].include?(value)
    end
  end

  def url
    if hathitrust_item_id.nil? || many_holdings?
      work_url
    else
      item_url
    end
  end

  private

  def access_rights
    Array(document['ht_access_sim'])
  end

  def hathitrust_item_id
    document.first('ht_htid_ssim')
  end

  def hathitrust_work_id
    document.first('ht_bib_key_ssim')
  end

  def work_url
    work_base_url = "https://catalog.hathitrust.org/Record/#{hathitrust_work_id}"
    return work_base_url if publicly_available?

    "#{work_base_url}?signon=swle:#{stanford_shib_id}"
  end

  def item_url
    return item_target(hathitrust_item_id) if publicly_available?

    "https://babel.hathitrust.org/Shibboleth.sso/Login?entityID=#{stanford_shib_id}&target=#{item_target(hathitrust_item_id)}"
  end

  def stanford_shib_id
    'urn:mace:incommon:stanford.edu'
  end

  def many_holdings?
    document.holdings.items.many?(&:present?)
  end

  def fulltext_available?
    document&.index_links&.fulltext&.any? || document&.index_links&.sfx&.any?
  end

  def item_target(id)
    "https://babel.hathitrust.org/cgi/pt?id=#{ERB::Util.url_encode(id)}"
  end
end
