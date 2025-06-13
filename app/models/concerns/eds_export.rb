# frozen_string_literal: true

module EdsExport
  def self.extended(document)
    document.will_export_as(:ris, 'application/x-research-info-systems')
  end

  def export_as_ris
    dig('exports', 'Data') if dig('exports', 'Format') == 'RIS'
  end
end
