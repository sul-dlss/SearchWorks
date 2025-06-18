# frozen_string_literal: true

class ArchivesResult
  include ActiveModel::API
  attr_accessor :title, :icon, :physical, :description, :link
end
