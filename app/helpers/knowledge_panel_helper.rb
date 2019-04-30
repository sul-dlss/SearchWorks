module KnowledgePanelHelper
  def knowledge_panel_uri_map(authorities, rwos)
    uris = [authorities, rwos].flatten.compact

    uris.group_by do |u|
      URI.parse(u).host
    end
  end

  def wof_from_query(p = params)
    subject_terms = (p['search_field'] == 'subject_terms') && p['q'] && Wof[p['q'].gsub('"', '')]
    genre_facet = p[:f] && p[:f][:genre_ssim] && Wof[p[:f][:genre_ssim].first]
    geo_facet = p[:f] && p[:f][:geographic_facet] && Wof[p[:f][:geographic_facet].first]
    topic_facet = p[:f] && p[:f][:topic_facet] && Wof[p[:f][:topic_facet].first]

    [subject_terms, genre_facet, geo_facet, topic_facet].select { |w| w.is_a?(Hash) }.first
  end
end
