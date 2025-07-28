# frozen_string_literal: true

class EdsDocument # rubocop:disable Metrics/ClassLength
  EDS_RESTRICTED_PATTERN = /^This title is unavailable for guests, please login to see more information./

  include Blacklight::Document
  include Blacklight::Document::ActiveModelShim

  include EdsLinks
  include EdsSubjects
  include EdsExport

  # self.unique_key = 'id'

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  use_extension(Searchworks::Document::Sms)

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  use_extension(EdsExport, &:eds_ris_export?)

  sw_field_semantics = {
    title: %w[title_display eds_title],
    author: 'author_display',
    language: 'language_facet',
    format: 'format'
  }

  ##
  # Use catalog_field_semantics by default
  field_semantics.merge!(sw_field_semantics)

  delegate :dig, to: :@_source

  def document_formats
    [eds_publication_type]
  end

  def eds_title(default: 'This title is unavailable for guests, please login to see more information.')
    # temp. stub for testing fixtures
    return @_source['eds_title'] if @_source.key?('eds_title')

    dig(*bib_entity_path, 'Titles')&.find { |item| item['Type'] == 'main' }&.dig('TitleFull') ||
      find_item_data(name: 'Title') ||
      default
  end

  def eds_source_title
    source_title = dig(*bib_part_path, 'BibEntity', 'Titles')&.find { |item| item['Type'] == 'main' }&.dig('TitleFull') ||
                   eds_composed_title

    return if source_title == eds_title

    source_title
  end

  def eds_fulltext_links
    Array(fulltext_links)
  end

  def eds_html_fulltext
    return unless eds_html_fulltext_available? && dig('FullText', 'Text', 'Value').present?

    CGI.unescapeHTML(dig('FullText', 'Text', 'Value'))
  end

  def eds_html_fulltext_available?
    dig('FullText', 'Text', 'Availability') == '1'
  end

  def eds_fulltext_link
    {
      'id' => eds_database_id,
      'links' => fulltext_links + non_fulltext_links
    }
  end

  def fulltext_links
    fulltext_links = []

    fulltext_links += (dig('FullText', 'Links') || []).filter_map do |link|
      case link['Type']
      when 'pdflink'
        link_label = 'PDF Full Text'
        link_icon = 'PDF Full Text Icon'
      when 'ebook-pdf'
        link_label = 'PDF eBook Full Text'
        link_icon = 'PDF eBook Full Text Icon'
      when 'ebook-epub'
        link_label = 'ePub eBook Full Text'
        link_icon = 'ePub eBook Full Text Icon'
      when 'other'
        link_label = 'Full Text'
      end

      link_url = link['Url'] || 'detail'
      link_url = "#{Settings.libraries.default.ezproxy_host}#{{ qurl: link['Url'] }.to_param}" if link['Type'] == 'other' && link['Url'].present?

      { url: link_url, label: link_label, icon: link_icon, type: link['Type'], expires: true } if link_label
    end

    fulltext_links += (dig('FullText', 'CustomLinks') || []).map do |link|
      link_url = link['Url']
      link_url = add_protocol(link_url)
      link_label = link['Text']
      link_icon = link['Icon']
      { url: link_url, label: link_label, icon: link_icon, type: 'customlink-fulltext', expires: false }
    end

    fulltext_links
  end

  def non_fulltext_links
    dig('CustomLinks')&.map do |link|
      link_url = link['Url']
      link_url = add_protocol(link_url)
      link_label = link['Text']
      link_icon = link['Icon']

      { url: link_url, label: link_label, icon: link_icon, type: 'customlink-other', expires: false }
    end
  end

  # add protocol if needed
  def add_protocol(url)
    return url if url[%r{\Ahttps?://}]

    "https://#{url}"
  end

  def eds_database_id
    dig('Header', 'DbId')
  end

  def eds_authors
    deep_find_all(dig(*bib_relationshps_path), 'NameFull')&.to_a
  end

  def eds_publication_date
    bib_publication_date = dig(*bib_part_path, 'BibEntity', 'Dates')&.find { |x| x['Type'] == 'published' && x.key?('Y') && x.key?('M') && x.key?('D') }

    return find_item_data(name: 'DatePub') unless bib_publication_date

    "#{bib_publication_date['Y']}-#{bib_publication_date['M']}-#{bib_publication_date['D']}"
  end

  def eds_publication_year
    bib_publication_date = dig(*bib_part_path, 'BibEntity', 'Dates')&.find { |x| x['Type'] == 'published' && x.key?('Y') && x.key?('M') && x.key?('D') }

    return find_item_data(name: 'DatePub') unless bib_publication_date

    bib_publication_date['Y']
  end

  def eds_publication_type
    dig('Header', 'PubType') || find_item_data(name: 'TypePub')
  end

  def eds_document_doi
    find_item_data(name: 'DOI') || dig(*bib_entity_path, 'Identifiers')&.find { |x| x['Type'] == 'doi' }&.dig('Value')
  end

  def eds_database_name
    dig('Header', 'DbLabel')
  end

  def eds_languages
    find_item_data(name: 'Language') || dig(*bib_entity_path, 'Languages')&.pluck('Text')
  end

  def bib_part_path
    [:RecordInfo, :BibRecord, :BibRelationships, :IsPartOfRelationships, 0]
  end

  def bib_entity_path
    %i[RecordInfo BibRecord BibEntity]
  end

  def bib_relationshps_path
    %i[RecordInfo BibRecord BibRelationships]
  end

  def items_path
    %i[Items]
  end

  def eds_author_affiliations
    find_item_data(name: 'AffiliationAuthor')
  end

  def eds_composed_title
    find_item_data(name: 'TitleSource')
  end

  def eds_abstract
    find_item_data(name: 'Abstract')
  end

  def eds_notes
    find_item_data(name: 'Notes')
  end

  def eds_subjects_person
    Subject.from(find_item_data(name: 'SubjectPerson'))
  end

  def eds_series
    find_item_data(name: 'SeriesInfo')
  end

  def eds_publisher
    find_item_data(name: 'Publisher')
  end

  def eds_document_oclc
    find_item_data(name: 'OCLC')
  end

  def eds_document_type
    find_item_data(name: 'TypeDocument')
  end

  def eds_other_titles
    find_item_data(name: 'TitleAlt')
  end

  def eds_physical_description
    find_item_data(name: 'PhysDesc')
  end

  def eds_author_supplied_keywords
    Subject.from(find_item_data(name: 'Keyword'))
  end

  def eds_publication_info
    find_item_data(label: 'Publication Information')
  end

  def eds_publication_status
    find_item_data(label: 'Publication Status')
  end

  def eds_subjects
    Subject.from(Array(find_item_data(name: 'Subject', label: 'Subject Terms', group: 'Su') ||
      find_item_data(name: 'Subject', label: 'Subject Indexing', group: 'Su') ||
      find_item_data(name: 'Subject', label: 'Subject Category', group: 'Su') ||
      find_item_data(name: 'Subject', label: 'KeyWords Plus', group: 'Su') ||
      eds_bib_subjects))
  end

  def deep_find_all(object, key, &)
    return to_enum(:deep_find_all, object, key) unless block_given?

    case object
    when Hash
      object.each do |k, v|
        if k.to_s == key.to_s
          yield v
        elsif v.is_a?(Hash) || v.is_a?(Array)
          deep_find_all(v, key, &)
        end
      end
    when Array
      object.each do |item|
        deep_find_all(item, key, &) if item.is_a?(Hash) || item.is_a?(Array)
      end
    end
  end

  def eds_bib_subjects
    deep_find_all(dig(*bib_entity_path), :SubjectFull)&.to_a
  end

  def eds_subjects_geographic
    Subject.from(find_item_data(name: 'SubjectGeographic', label: 'Geographic Terms', group: 'Su') ||
      find_item_data(name: 'Subject', label: 'Subject Geographic', group: 'Su'))
  end

  def find_item_data(name: nil, label: nil, group: nil)
    sanitize_data(dig(*items_path)&.find { |item| (name.nil? || item['Name'] == name) && (label.nil? || item['Label'] == label) && (group.nil? || item['Group'] == group) })
  end

  def eds_volume
    dig(*bib_part_path, :Numbering)&.find { |x| x['Type'] == 'volume' }&.dig('Value')
  end

  def eds_issue
    dig(*bib_part_path, :Numbering)&.find { |x| x['Type'] == 'issue' }&.dig('Value')
  end

  def eds_page_start
    deep_find_all(dig(*bib_entity_path), :StartPage)&.first
  end

  def eds_page_count
    deep_find_all(dig(*bib_entity_path), :PageCount)&.first
  end

  def eds_isbns
    eds_bib_entity_isbns.presence || eds_related_isbns
  end

  def eds_issns
    dig(*bib_part_path, :BibEntity, :Identifiers)&.select { |x| x['Type'] == 'issn' && x['Type'].exclude?('locals') }&.pluck('Value')
  end

  def eds_bib_entity_isbns
    dig(*bib_part_path, :BibEntity, :Identifiers)&.select { |x| x['Type'] == 'isbn' && x['Type'].exclude?('locals') }&.pluck('Value')
  end

  def eds_related_isbns
    isbns = find_item_data(label: 'Related ISBNs')

    return unless isbns

    isbns.split.map do |item|
      item.gsub(/\.$/, '')
    end
  end

  # decode & sanitize html tags found in item data; apply any special transformations
  def sanitize_data(item)
    return unless item&.dig('Data')

    data = item['Data']

    # group-specific transformations
    if item['Group']
      group = item['Group']
      data = add_subject_searchlinks(data) if group == 'Su'
    end

    html_decode_and_sanitize(data)
  end

  # Decode any html elements and then run it through sanitize to preserve entities (eg: ampersand) and strip out
  # elements/attributes that aren't explicitly whitelisted.
  # The RELAXED config: https://github.com/rgrove/sanitize/blob/master/lib/sanitize/config/relaxed.rb
  def html_decode_and_sanitize(data, config = nil)
    default_config = Sanitize::Config.merge(Sanitize::Config::RELAXED,
                                            elements: Sanitize::Config::RELAXED[:elements] +
                                                %w[relatesto searchlink ephtml],
                                            attributes: Sanitize::Config::RELAXED[:attributes].merge(
                                              'searchlink' => %w[fieldcode term]
                                            ))
    sanitize_config = config.nil? ? default_config : config
    # Increasing the number of attributes may help deal with errant "<" that
    # makes the parser think a single element has multiple attributes
    # when there are no elements.
    sanitize_config[:parser_options] = { max_attributes: 3000 }

    html = CGI.unescapeHTML(data.to_s)
    # need to double-unescape data with an ephtml section
    if html.include?('<ephtml>')
      html = CGI.unescapeHTML(html)
      html = html.gsub('\"', '"')
      html = html.gsub("\\n ", '')
    end

    begin
      sanitized_html = Sanitize.fragment(html, sanitize_config)
    rescue ArgumentError => e
      # We still want to notify honeybadger but can provide more information
      # about the html
      Honeybadger.notify(e, error_message: 'Error with arguments passed to Sanitize/Nokogiri', context: { html: })
      # Return an empty string to allow the page to still load
      return ''
    end
    # sanitize 5.0 fails to restore element case after doing lowercase
    sanitized_html = sanitized_html.gsub('<searchlink', '<searchLink')
    sanitized_html.gsub('</searchlink>', '</searchLink>')
  end

  # add searchlinks when they don't exist
  def add_subject_searchlinks(data)
    subjects = data
    if data.include? '&lt;link '
      subjects = eds_bib_subjects
      subjects = subjects.map do |su|
        "&lt;searchLink fieldCode=&quot;DE&quot; term=&quot;%22#{su}%22&quot;&gt;#{su}&lt;/searchLink&gt;"
      end.join('&lt;br /&gt;')
    end
    unless subjects.include? 'searchLink'
      subjects = subjects.split('&lt;br /&gt;').map do |su|
        "&lt;searchLink fieldCode=&quot;DE&quot; term=&quot;%22#{su}%22&quot;&gt;#{su}&lt;/searchLink&gt;"
      end.join('&lt;br /&gt;')
    end
    subjects
  end

  delegate :empty?, :blank?, to: :to_h

  ##
  # Overriding method until we get a version of Blacklight with new functionality
  def to_semantic_values
    semantic_value_hash = super
    semantic_value_hash = self.class.field_semantics.each_with_object(semantic_value_hash) do |(key, field_names), hash|
      ##
      # Handles single string field_name or an array of field_names
      value = Array.wrap(field_names).map { |field_name| self[field_name] }.flatten.compact

      # Make single and multi-values all arrays, so clients
      # don't have to know.
      hash[key] = Array.wrap(value) unless value.empty?
    end

    semantic_value_hash || {}
  end

  def key?(key)
    respond_to?(key)
  end

  def [](key)
    return unless respond_to?(key)

    public_send(key)
  end

  def id
    # temp. stub for testing fixtures
    return @_source['id'].to_s if @_source.key?('id')

    [@_source.dig('Header', 'DbId'), @_source.dig('Header', 'An')].join('__')
  end

  def to_param
    id.gsub('/', '%2F')
  end

  def eds?
    true
  end

  def eds_ris_export?
    dig('exports', 'Format') == 'RIS'
  end

  def preferred_online_links
    eds_links&.fulltext || []
  end

  def html_fulltext?
    eds_html_fulltext_available?
  end

  def research_starter?
    # TODO: we probably need a better way to determine this
    self['eds_database_name'] == 'Research Starters'
  end

  def eds_restricted?
    # TODO: we probably need a better way to determine this
    self['eds_title'] =~ ::EdsDocument::EDS_RESTRICTED_PATTERN
  end

  concerning :EdsCitations do
    def citable?
      eds_citations.present?
    end

    def citations
      eds_citations.presence || Citation::NULL_CITATION
    end

    def eds_citations
      return {} if dig('styles', 'Citations').blank?

      Citations::EdsCitation.new(eds_citations: dig('styles', 'Citations')).all_citations.presence || {}
    end
  end

  # These stub methods are used by components shared with SolrDocument:
  def is_a_database? = false
  def druid = nil
  def eresources_library_display_name = nil
  def mods = nil
  def oclc_number = nil

  def display_type = 'eds'

  def holdings
    Holdings.new([], [])
  end

  def marc_links
    Links.new([])
  end
end
