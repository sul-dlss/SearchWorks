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

  def display_author_knowledge_panel?(p = params)
    p[:wdid].present? &&
      p[:q].present? &&
      p[:search_field] == 'search_author' &&
      p[:wdid].match?(/^Q\d+$/)
  end

  def author_uris_from_results(p = params)
    return if (author_facet = p.dig(:f, :author_person_facet)).blank?
    return if @document_list.blank?

    @document_list.collect do |document|
      next unless document[:author_struct]
      next unless document[:author_struct]&.first&.values&.flatten&.all? { |struct| struct.is_a?(Hash) }

      document[:author_struct].first.values.flatten.collect do |author_data|
        next unless author_data[:link] == author_facet.first

        [author_data[:authorities], author_data[:rwo]]
      end
    end.flatten.compact
  end
end
