require 'nokogiri'
require 'cgi'

module ArticleHelper
  def article_search?
    controller_name == 'article'
  end

  def link_subjects(options = {})
    return unless options[:value]
    separators = options.dig(:config, :separator_options) || {}
    values = render_text_from_html(options[:value])
    values.collect do |value|
      link_to value, article_index_path(q: "\"#{value}\"", search_field: :subject)
    end.to_sentence(separators).html_safe # this is what Blacklight's Join step does
  end

  def link_authors(options = {})
    return if options[:value].blank?
    separators = options.dig(:config, :separator_options) || {}
    values = render_text_from_html(options[:value])
    values.collect do |value|
      search, label_relator = parse_out_relators(value)
      (link_to search, article_index_path(q: "\"#{search}\"", search_field: :author)) + "#{label_relator}"
    end.to_sentence(separators).html_safe # this is what Blacklight's Join step does
  end

  def strip_author_relators(options = {})
    return if options[:value].blank?
    separators = options.dig(:config, :separator_options) || {}
    values = render_text_from_html(options[:value])
    values.collect do |value|
      parse_out_relators(value).first # ignore second return value (label)
    end.to_sentence(separators).html_safe # this is what Blacklight's Join step does
  end

  def link_to_doi(options = {})
    doi = options[:value].try(:first)
    return if doi.blank?
    url = 'https://doi.org/' + doi.to_s
    link_to(doi, url)
  end

  def mark_html_safe(options = {})
    return unless options[:value].present?
    separators = options.dig(:config, :separator_options) || {}
    options[:value].map(&:to_s).to_sentence(separators).html_safe
  end

  def sanitize_fulltext(options = {})
    return unless options[:value].present?
    return safe_join(options[:value]) if @document && @document.research_starter?
    separators = options.dig(:config, :separator_options) || {}
    textblock = options[:value].map(&:to_s).to_sentence(separators)
    textblock = Nokogiri::HTML.fragment(CGI.unescapeHTML(textblock))
    textblock.search('anid').remove
    textblock = textblock.to_html
    sanitize(textblock).html_safe
  end

  def render_text_from_html(values)
    values = Array.wrap(values)
    return [] if values.blank?
    values.map do |value|
      doc = Nokogiri::HTML(CGI.unescapeHTML(value))
      doc.xpath('//text()').to_a.map(&:to_s)
    end.flatten
  end

  #
  def transform_research_starter_text(options = {})
    return if options[:value].blank?
    doc = Nokogiri::HTML.fragment(CGI.unescapeHTML(options[:value]))
    doc.search('anid', 'title').remove # remove EDS header content

    # Translate EDS elements into regular HTML
    element_rename(doc, 'bold', 'b')
    element_rename(doc, 'emph', 'i')
    element_rename(doc, 'ulist', 'ul')
    element_rename(doc, 'item', 'li')
    element_rename(doc, 'subs', 'sub')
    element_rename(doc, 'sups', 'sup')

    # Rewrite EDS eplinks into actual hyperlinks to other research starters
    doc.search('eplink').each do |node|
      node.name = 'a'
      node['href'] = article_path(id: "#{@document['eds_database_id']}__#{node['linkkey']}")
    end

    # Wrap images into figures with captions
    doc.search('img').each do |node|
      figure = Nokogiri::HTML.fragment("
      <div class=\"research-starter-figure clearfix\">
        #{node.to_html}<span>#{node['title']}</span>
      </div>")
      node.replace(figure)
    end
    sanitize(doc.to_html, tags: %w[p a b i ul li img div span sub sup])
  end

  private

  RELATOR_TERMS = %w[Author Originator]

  def parse_out_relators(value)
    value = value.dup
    label = ''
    RELATOR_TERMS.each do |relator|
      next unless value =~ /, #{relator}$/i
      label = ", #{relator}"
      value.gsub!(/, #{relator}$/i, '')
    end
    [value, label]
  end

  def element_rename(doc, from, to)
    doc.search(from).each do |node|
      node.name = to
    end
  end
end
