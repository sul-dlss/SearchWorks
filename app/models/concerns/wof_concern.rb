module WofConcern
  def wof
    Array.wrap(self[:geographic_facet]).map { |gf| Wof[gf] }.compact
  end
end
