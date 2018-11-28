# frozen_string_literal: true

xml.instruct!
xml.OpenSearchDescription(:xmlns => 'http://a9.com/-/spec/opensearch/1.1/', 'xmlns:moz' => 'http://www.mozilla.org/2006/browser/search/') do
  xml.ShortName(t(:default_title))
  xml.InputEncoding('UTF-8')
  xml.Description(t(:opensearch_description))
  xml.Url(type: 'text/html', template: root_url + '?q={searchTerms}')
  xml.moz(:SearchForm, root_url)
end
