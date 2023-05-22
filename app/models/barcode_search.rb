# frozen_string_literal: true

class BarcodeSearch
  attr_reader :barcode

  def initialize(barcode)
    @barcode = barcode
  end

  def document_id
    return if documents.blank?

    documents.first['id']
  end

  def as_json(*)
    { barcode:, id: document_id }
  end

  private

  def documents
    response.dig('response', 'docs') || []
  end

  def response
    @response ||= blacklight_solr.get('barcode', params: { n: barcode })
  end

  def blacklight_solr
    Blacklight.default_index.connection
  end
end
