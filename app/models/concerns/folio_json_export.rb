module FolioJsonExport
  def self.extended(document)
    document.will_export_as(:folio_json, 'application/json')
  end

  def export_as_folio_json
    {
      "holdings_json_struct" => JSON.parse(self[:holdings_json_struct].first),
      "folio_json_struct" => JSON.parse(self[:folio_json_struct].first)
    }.to_json
  end
end
