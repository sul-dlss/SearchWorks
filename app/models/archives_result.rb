# frozen_string_literal: true

class ArchivesResult
  include ActiveModel::API
  attr_accessor :title, :type, :physical, :description, :link

  def icon
    case type
    when 'collection'
      'archive.svg'
    when 'Series'
      'folder.svg'
    when 'File', 'Item'
      'file.svg'
    end
  end
end
