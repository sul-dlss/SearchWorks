# frozen_string_literal: true

class CatalogResult
  include ActiveModel::API
  attr_accessor :title, :format, :physical, :author, :description, :link, :pub_year, :fulltext_link_html

  FORMAT_TO_ICON = {
    'Archive/Manuscript' => 'box-1.svg',
    'Archived website' => 'network-web.svg',
    'Book' => 'notebook.svg',
    'Database' => 'window-search.svg',
    'Dataset' => 'graph-bar-2.svg',
    'Equipment' => 'plug-1.svg',
    'Image' => 'picture-2.svg',
    'Journal/Periodical' => 'book-open-4.svg',
    'Loose-leaf' => 'notepad-1.svg',
    'Map' => 'map-pin-1.svg',
    'Music recording' => 'turntable.svg',
    'Music score' => 'file-music-1.svg',
    'Newspaper' => 'newspaper.svg',
    'Object' => 'box-3.svg',
    'Software/Multimedia' => 'mouse.svg',
    'Sound recording' => 'microphone-3.svg',
    'Video' => 'camera-film-1.svg',
    'Video game' => 'game-controller-2.svg',
    'Video/Film' => 'camera-film-1.svg',
    'Website' => 'network-web.svg'
  }.freeze

  def icon
    FORMAT_TO_ICON.fetch(format, 'notebook.svg')
  end

  def html
    @html ||= Nokogiri::HTML(fulltext_link_html)
  end

  def fulltext_stanford_only?
    # Break up the HTML string into the pieces we use
    (html.css('[aria-label="Stanford-only"]').first || html.css('.stanford-only').first).present?
  end

  def link_html
    # Break up the HTML string into the pieces we use
    link = html.css('a').first&.to_html
    "<span class=\"text-green\">Available online ⮕</span> #{link}" if link
  end
end
