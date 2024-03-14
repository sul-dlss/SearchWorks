# frozen_string_literal: true

require 'nokogiri'
require 'cgi'

module ArticleHelper
  def article_search?
    controller_name == 'articles'
  end

  def article_selections?
    controller_name == 'article_selections'
  end

  def facet_options_presenter
    @facet_options ||= FacetOptionsPresenter.new(params:, context: self)
  end

  def link_subjects(options = {})
    separators = options.dig(:config, :separator_options) || {}
    subjects = @document.send(options[:field].to_sym) if options[:field].present? && @document.respond_to?(options[:field].to_sym)
    subjects ||= EdsSubjects::Subject.from(options[:value])
    subjects.map(&:to_html).to_sentence(separators).html_safe
  end

  def link_authors(options = {})
    return if options[:value].blank?

    separators = options.dig(:config, :separator_options) || {}
    values = render_text_from_html(options[:value])
    values.collect do |value|
      search, label_relator = parse_out_relators(value)
      (link_to search, articles_path(q: "\"#{search}\"", search_field: :author)) + "#{label_relator}"
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

  def clean_affiliations(options = {})
    return if options[:value].blank?

    separators = options.dig(:config, :separator_options) || {}
    affiliations = options[:value].map(&:to_s).to_sentence(separators)
    remove_eds_tag(affiliations, 'relatesto').html_safe
  end

  def link_to_doi(options = {})
    doi = options[:value].try(:first)
    return if doi.blank?

    url = 'https://doi.org/' + doi.to_s
    link_to(doi, url)
  end

  ##
  # EDS returns structured data (as XML) sometimes so use that
  # but when it's just a string, italicize the first phrase
  def italicize_composed_title(options = {})
    composed_title = options[:value].try(:first).to_s # We only compose the first value
    return if composed_title.blank?
    return composed_title.html_safe if /\<\/\w+\>/.match?(composed_title) # has XML so use as-is

    match = /^([^[:punct:]]+)(.*)$/.match(composed_title)
    return "<i>#{match[1]}</i>#{match[2]}".html_safe if match # italicize first phrase

    composed_title.html_safe
  end

  def mark_html_safe(options = {})
    return unless options[:value].present?

    separators = options.dig(:config, :separator_options) || {}
    options[:value].map(&:to_s).to_sentence(separators).html_safe
  end

  def sanitize_fulltext(options = {})
    return unless options[:value].present?
    return sanitize_research_starter(**options) if @document && @document.research_starter?

    separators = options.dig(:config, :separator_options) || {}
    fulltext = options[:value].map(&:to_s).to_sentence(separators)
    fulltext = remove_eds_tag(fulltext, 'anid')
    sanitize(fulltext).html_safe
  end

  def sanitize_research_starter(value:, document: nil, **_kwargs)
    return if value.blank?

    value = value.join("\n\n")

    doc = Nokogiri::HTML.fragment(CGI.unescapeHTML(value))
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
      node['href'] = article_path(id: "#{document['eds_database_id']}__#{node['linkkey']}")
    end

    # Wrap images into figures with captions
    doc.search('img').each do |node|
      figure = Nokogiri::HTML.fragment("
      <div class=\"research-starter-figure\">
        #{node.to_html}<span>#{node['title']}</span>
      </div>")
      node.replace(figure)
    end
    sanitize(doc.to_html, tags: %w[p a b i ul li img div span sub sup])
  end

  def remove_html_from_document_field(options = {})
    return if options[:value].blank?

    separators = options.dig(:config, :separator_options) || {}
    render_text_from_html(options[:value]).map(&:to_s).to_sentence(separators)
  end

  def render_text_from_html(values)
    values = Array.wrap(values)
    return [] if values.blank?

    values.map do |value|
      doc = Nokogiri::HTML(CGI.unescapeHTML(value))
      doc.xpath('//text()').to_a.map(&:to_s)
    end.flatten
  end

  private

  RELATOR_TERMS = %w[Author Originator]

  def parse_out_relators(value)
    value = value.dup
    label = ''
    RELATOR_TERMS.each do |relator|
      next unless /, #{relator}$/i.match?(value)

      label = ", #{relator}"
      value.gsub!(/, #{relator}$/i, '')
    end
    [value, label]
  end

  def remove_eds_tag(text, tag)
    text = Nokogiri::HTML.fragment(CGI.unescapeHTML(text))
    text.search(tag).remove
    text.to_html
  end

  def element_rename(doc, from, to)
    doc.search(from).each do |node|
      node.name = to
    end
  end
end
