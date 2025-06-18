# frozen_string_literal: true

class ArticleResult
  include ActiveModel::API

  attr_accessor :title, :format, :journal, :author, :description, :link, :fulltext_link_html,
                :pub_date, :composed_title, :fulltext_stanford_only

  alias fulltext_stanford_only? fulltext_stanford_only

  def icon
    'notebook.svg'
  end
end
