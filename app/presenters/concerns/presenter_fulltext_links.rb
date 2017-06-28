module PresenterFulltextLinks
  def fulltext_links
    field_key = configuration.index.fulltext_links_field
    document[field_key].collect do |link|
      "<li class=\"article-fulltext-link\">#{view_context.link_to(link['label'] || link['url'], link['url'])}</li>".html_safe
    end
  end
end
