# frozen_string_literal: true

class ArchivesResult
  include ActiveModel::API
  attr_accessor :title, :type, :physical, :description, :link

  def icon
    case type.downcase
    when 'collection'
      'archive.svg'
    when 'series'
      'folder.svg'
    when 'file', 'item'
      'file.svg'
    end
  end
end
