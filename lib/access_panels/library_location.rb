class LibraryLocation < AccessPanel
  delegate :present?, to: :locations
  def locations
    if @document.library_locations.present?
      @document.library_locations.locations
    end
  end
end
