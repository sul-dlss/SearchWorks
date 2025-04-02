# frozen_string_literal: true

module RisMapping
  def format_type
    format = fetch('format_main_ssim', [])
    if format.member?('Book')
      'BOOK'
    elsif format.member?('Journal/Periodical')
      'JOUR'
    else
      'GEN'
    end
  end

  def purl_url
    "#{Settings.PURL_EMBED_RESOURCE}/#{fetch('druid')}" if fetch('druid', false)
  end

  def searchworks_url
    Rails.application.routes.url_helpers.solr_document_url(fetch('id'), host: 'https://searchworks.stanford.edu')
  end

  def self.field_mapping
    { TY: proc { format_type },
      TI: 'title_display',
      AU: 'author_person_facet',
      PB: 'pub_display',
      KW: 'subject_all_search',
      LA: 'language',
      Y1: 'pub_date',
      CY: 'pub_country',
      AB: 'summary_display',
      C3: 'physical',
      CN: 'lc_assigned_callnum_ssim',
      H1: 'building_facet',
      SN: 'isbn_display',
      DP: proc { searchworks_url },
      UR: proc { searchworks_url },
      L3: proc { purl_url } }
  end
end
