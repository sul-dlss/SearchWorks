# frozen_string_literal: true

class EarthworksResult
  include ActiveModel::API
  attr_accessor :title, :format, :icon, :author, :description, :link, :coverage, :date
end
