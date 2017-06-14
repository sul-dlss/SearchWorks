class AccessPanels
  class LibraryLocation < ::AccessPanel
    delegate :present?, to: :libraries
    def libraries
      if @document.holdings.present?
        @document.holdings.libraries.select(&:present?)
      end
    end
  end
end
