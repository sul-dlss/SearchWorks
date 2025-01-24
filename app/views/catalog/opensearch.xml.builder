# frozen_string_literal: true

xml.instruct! :xml, :version=>'1.0'
xml.OpenSearchDescription(:xmlns=>'http://a9.com/-/spec/opensearch/1.1/') {
  xml.ShortName application_name
  xml.Description "#{application_name} Search"
  xml.Image "https://cdn.jsdelivr.net/gh/sul-dlss/component-library@v2025-01-24/styles/icon.png", height: 512, width: 512, type: 'image/png'
  xml.Contact
  xml.Url :type=>'text/html', :method=>'get', :template=>"#{url_for :controller=>'catalog', :only_path => false}?q={searchTerms}&amp;page={startPage?}"
  xml.Url :type=>'application/rss+xml', :method=>'get', :template=>"#{url_for :controller=>'catalog', :only_path => false}.rss?q={searchTerms}&amp;page={startPage?}"
  xml.Url :type => 'application/x-suggestions+json', :method=>'get',
          :template => "#{url_for :controller=>'catalog',:action => 'opensearch', :format=> 'json', :only_path => false}?q={searchTerms}"
}
