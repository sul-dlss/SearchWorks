# frozen_string_literal: true

class CatalogResult
  include ActiveModel::API
  attr_accessor :title, :format, :physical, :author, :description, :link, :pub_year, :resource_links

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

  def preferred_resource_link
    resource_links&.first&.with_indifferent_access
  end

  def fulltext_stanford_only?
    preferred_resource_link&.dig(:stanford_only)
  end

  def link_html
    return unless preferred_resource_link

    "<span class=\"text-green\">Available online ⮕</span> #{ApplicationController.helpers.link_to preferred_resource_link[:link_text],
                                                                                                  preferred_resource_link[:href]}"
  end
end
