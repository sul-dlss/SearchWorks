class LibraryLocation < AccessPanel
  delegate :present?, to: :libraries
  def libraries
    if @document.holdings.present?
      @document.holdings.libraries
    end
  end
end
