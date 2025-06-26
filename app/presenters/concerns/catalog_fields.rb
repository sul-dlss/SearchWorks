# frozen_string_literal: true

module CatalogFields
  def display_type(*)
    document.display_type
  end

  def document_format
    document.document_formats.first
  end

  def main_title_date
    "(#{document.first('pub_year_ss')})" if document.key? 'pub_year_ss'
  end

  delegate :eds_ris_export?, to: :document
end
