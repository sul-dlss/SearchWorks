# frozen_string_literal: true

# Export stored Cocina JSON from Solr
module CocinaExport
  def self.extended(document)
    document.will_export_as(:cocina_json, 'application/json')
  end

  def export_as_cocina_json
    fetch('cocina_struct')&.first
  end
end
