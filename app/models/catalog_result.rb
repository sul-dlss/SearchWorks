# frozen_string_literal: true

class CatalogResult
  include ActiveModel::API
  attr_accessor :title, :format, :physical, :author, :description, :link, :pub_year

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
    'Video' => 'camera-film-1.svg'
  }.freeze

  def icon
    FORMAT_TO_ICON.fetch(format, 'notebook.svg')
  end
end
