# frozen_string_literal: true

class ExhibitsResult
  include ActiveModel::API
  attr_accessor :title, :description, :link, :thumbnail
end
