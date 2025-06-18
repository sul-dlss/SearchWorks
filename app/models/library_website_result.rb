# frozen_string_literal: true

class LibraryWebsiteResult
  include ActiveModel::API
  attr_accessor :title, :link, :description
end
