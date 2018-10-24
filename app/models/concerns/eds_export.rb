module EdsExport
  def self.extended(document)
    document.will_export_as(:ris)
  end

  def export_as_ris
    self['eds_citation_exports']&.select { |e| e['id'] == 'RIS' }&.first&.[]('data')
  end
end
