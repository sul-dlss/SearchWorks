require 'nokogiri'
require 'cgi'

module ArticleHelper
  def article_search?
    controller_name == 'article'
  end

  def article_restricted?(document)
    # TODO: we probably need a better way to determine this
    document['eds_title'] =~ /^This title is unavailable for guests, please login to see more information./
  end

  def link_to_doi(options = {})
    doi = options[:value].try(:first)
    return if doi.blank?
    url = 'https://doi.org/' + doi.to_s
    link_to(doi, url)
  end

  def render_text_from_html(options = {})
    html = options[:value].try(:first)
    return if html.blank?
    doc = Nokogiri::HTML(CGI.unescapeHTML(html))
    sep = options[:config][:seperator] if options[:config].present?
    safe_join(doc.xpath('//text()').to_a, sep)
  end
end
