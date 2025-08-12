# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks
  include SelectionsCount

  configure_blacklight do |config|
    config.default_solr_params = {
      qt: 'document',
      q: '*:*',
      rows: 20
    }
    config.sort_fields.delete('relevance')
    config.sort_fields.delete('new-to-libs')
  end

  # Overidden from Blacklight to add our tabbed interface
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks.where(record_type: 'catalog')
    @response = search_service.search_results
    @document_list = @response.documents

    @catalog_count = selections_counts.catalog
    @article_count = selections_counts.articles

    respond_to do |format|
      format.html {}
      format.rss  { render layout: false }
      format.atom { render layout: false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  protected

  def permit_bookmarks
    params.permit(bookmarks: [:document_id, :document_type, :record_type])
  end
end
