# frozen_string_literal: true

module FolioJsonExport
  def self.extended(document)
    document.will_export_as(:folio_json, 'application/json')
  end

  def export_as_folio_json
    {
      "holdings_json_struct" => first('holdings_json_struct') || {},
      "folio_json_struct" => JSON.parse(first('folio_json_struct') || '{}'),
      "marc_json_struct" => JSON.parse(first('marc_json_struct') || '{}')
    }.to_json
  end
end
