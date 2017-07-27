module EdsLinks
  def eds_links
    @eds_links ||= EdsLinks::Processor.new(self)
  end

  class Processor < SearchWorks::Links
    def all
      link_fields.map do |link_field|
        SearchWorks::Links::Link.new(
          text: relabel_link(link_field)['label'],
          href: link_field['url'],
          fulltext: show_link?(link_fields, link_field),
          sfx: sfx_link?(link_field)
        )
      end
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

      case map[:category]
      when 1, 2
        true
      when 3, 4
        !link_within_priority?(links, map[:category] - 1)
      end
    end

    # does this link have a priority <= given priority?
    def link_within_priority?(links, priority)
      links.each do |link|
        map = to_link_mapping(link)
        return true if map.present? && map[:category] <= priority
      end
      false
    end

    def sfx_link?(link)
      (to_link_mapping(link) || {})[:category] == 3
    end

    # Unfortunately we can only do this mapping via the EDS Label
    LINK_MAPPING = {
      'HTML full text'.downcase =>           { label: 'View full text', category: 1 },
      'PDF full text'.downcase =>            { label: 'View/download full text PDF', category: 2 },
      'Check SFX for full text'.downcase =>  { label: 'View full text on content provider\'s site', category: 3 },
      'View request options'.downcase =>     { label: 'Find it in print or via interlibrary services', category: 4 }
    }.freeze

    def to_link_mapping(link)
      LINK_MAPPING[link['label'].downcase] if link['label'].present?
    end

    def link_fields
      @document['eds_fulltext_links'] || []
    end
  end
end
