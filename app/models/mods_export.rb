# frozen_string_literal: true

module ModsExport
  def self.extended(document)
    document.will_export_as(:mods, 'application/mods+xml')
  end

  def export_as_mods
    fetch('modsxml')
  end
end
