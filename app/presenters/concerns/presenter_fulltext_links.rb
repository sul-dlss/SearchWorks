module PresenterFulltextLinks
  def fulltext_links
    links = document[configuration.index.fulltext_links_field]
    links.collect do |link|
      if show_link?(links, link)
        link = relabel_link(link)
        "<li class=\"article-fulltext-link\">#{view_context.link_to(link['label'], link['url'])}</li>".html_safe
      end
    end.compact
  end

  private

  def relabel_link(link)
    link = link.dup
    map = to_link_mapping(link)
    link['label'] = map[:label] if map.present?
    link
  end

  # Link types are prioritized as follows:
  #
  # 1 and 2 are preferred, and can coexist
  # show 3 only if there's no 1 or 2
  # show 4 only if there's no 1-3
  def show_link?(links, link)
    map = to_link_mapping(link)
    return false if map.blank? # drop links that don't have a mapping

    case map[:priority]
    when 1, 2
      true
    when 3, 4
      !link_within_priority?(links, map[:priority] - 1)
    end
  end

  # does this link have a priority <= given priority?
  def link_within_priority?(links, priority)
    links.each do |link|
      map = to_link_mapping(link)
      return true if map.present? && map[:priority] <= priority
    end
    false
  end

  # Unfortunately we can only do this mapping via the EDS Label
  LINK_MAPPING = {
    'HTML full text'.downcase =>           { label: 'View full text', priority: 1 },
    'PDF full text'.downcase =>            { label: 'View/download full text PDF', priority: 2 },
    'Check SFX for full text'.downcase =>  { label: 'View full text on content provider\'s site', priority: 3 },
    'View request options'.downcase =>     { label: 'Find it in print or via interlibrary services', priority: 4 }
  }.freeze

  def to_link_mapping(link)
    LINK_MAPPING[link['label'].downcase] if link['label'].present?
  end
end
