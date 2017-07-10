require 'nokogiri'
require 'cgi'

module ArticleHelper
  def article_search?
    controller_name == 'article'
  end

  def search_session
    {} # TODO: placeholder
  end

  def current_search_session
    {} # TODO: placeholder
  end

  def article_restricted?(document)
    # TODO: we probably need a better way to determine this
    document['eds_title'] =~ /^This title is unavailable for guests, please login to see more information./
  end

  def link_subjects(options = {})
    return unless options[:value]
    separators = options.dig(:config, :separator_options) || {}
    values = render_text_from_html(options[:value])
    values.collect do |value|
      # TODO: Remove DE when we are able to move to a (hidden) search field
      link_to value, article_index_path(q: "DE \"#{value}\"")
    end.to_sentence(separators).html_safe # this is what Blacklight's Join step does
  end

  def link_to_doi(options = {})
    doi = options[:value].try(:first)
    return if doi.blank?
    url = 'https://doi.org/' + doi.to_s
    link_to(doi, url)
  end

  def strip_html_from_solr_field(options = {})
    return unless options[:value]
    separators = options.dig(:config, :separator_options) || {}
    options[:value].collect do |value|
      safe_join(render_text_from_html(value))
    end.to_sentence(separators).html_safe # this is what Blacklight's Join step does
  end

  def render_text_from_html(values)
    values = Array.wrap(values)
    return [] if values.blank?
    values.map do |value|
      doc = Nokogiri::HTML(CGI.unescapeHTML(value))
      doc.xpath('//text()').to_a.map(&:to_s)
    end.flatten
  end
end
