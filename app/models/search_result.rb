# frozen_string_literal: true

class SearchResult
  include ActiveModel::API
  attr_accessor :title, :format, :icon, :physical, :author, :journal, :imprint, :description,
                :online_badge, :link, :thumbnail, :fulltext_link_html, :pub_date, :pub_year,
                :composed_title, :coverage, :date
end
