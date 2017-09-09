module PresenterResearchStarter
  # TODO: maybe this should go in the pipeline and only run on document.research_starter?
  def transform_research_starter_text
    value = document['eds_html_fulltext']
    return if value.blank?
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
      node['href'] = view_context.article_path(id: "#{document['eds_database_id']}__#{node['linkkey']}")
    end

    # Wrap images into figures with captions
    doc.search('img').each do |node|
      figure = Nokogiri::HTML.fragment("
      <div class=\"research-starter-figure clearfix\">
        #{node.to_html}<span>#{node['title']}</span>
      </div>")
      node.replace(figure)
    end
    document['eds_html_fulltext'] = view_context.sanitize(doc.to_html, tags: %w[p a b i ul li img div span sub sup])
  end

  private

  def element_rename(doc, from, to)
    doc.search(from).each do |node|
      node.name = to
    end
  end
end
