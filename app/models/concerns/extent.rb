module Extent
  def extent_label
    sanitized_format || "PHYSICAL EXTENT"
  end

  def extent
    Array[self[:physical]].flatten.join(', ')
  end

  private

  def sanitized_format
    if self[format_key].present?
      self[format_key].reject do |format|
        format == 'Database'
      end.first.try(:upcase)
    end
  end
end
