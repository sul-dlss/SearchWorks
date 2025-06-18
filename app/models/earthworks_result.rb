# frozen_string_literal: true

class EarthworksResult
  include ActiveModel::API
  attr_accessor :title, :format, :author, :description, :link, :coverage, :date

  def icon
    return unless format

    path = "earthworks/#{format.gsub(' ', '_').downcase}.svg"

    path if File.exist? Rails.root + "app/assets/images/#{path}"
  end
end
