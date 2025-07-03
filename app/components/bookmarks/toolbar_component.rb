# frozen_string_literal: true

module Bookmarks
  class ToolbarComponent < ViewComponent::Base
    def initialize(document_ids:)
      @document_ids = document_ids
      super
    end

    attr_reader :document_ids

    def bookmarks_count
      helpers.current_user.bookmarks.count
    end

    def citation_href
      polymorphic_path(:citation_solr_documents, sort: params[:sort], per_page: params[:per_page], id: document_ids)
    end

    def email_href
      email_bookmarks_path(sort: params[:sort], per_page: params[:per_page], id: document_ids)
    end
  end
end
