# Mixin to provide a display_type string for determining which
# partial for Blacklight to render. This handles translating
# the formats and whitelisting supported format types.
module DisplayType
  def display_type
    return nil if eds?
    @display_type ||= [marc_or_mods, collection_suffix].compact.join('_')
  end

  private

  def marc_or_mods
    return 'mods' if mods?
    'marc'
  end

  def collection_suffix
    return unless is_a_collection?
    'collection'
  end
end
