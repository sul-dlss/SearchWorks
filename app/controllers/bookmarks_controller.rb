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

  def clear
    if clear_bookmarks
      flash[:success] = I18n.t('blacklight.bookmarks.clear.success')
    else
      flash[:error] = I18n.t('blacklight.bookmarks.clear.failure')
    end
    redirect_back fallback_location: bookmarks_url
  end

  # Overrides Blacklight::BookmarksController#create_response
  def create_response(_success)
    @id = @bookmarks.first.fetch(:document_id)
    # Renders turbo_stream response
  end

  # Overrides Blacklight::BookmarksController#destroy_response
  def destroy_response(_success)
    @id = @bookmarks.first.fetch(:document_id)

    # Renders turbo_stream response
  end

  protected

  # Clears bookmarks from an ActiveRecord CollectionProxy
  # and deletes bookmarks from an AssociationRelation (and returns true)
  def clear_bookmarks
    return current_or_guest_user.bookmarks.clear unless clear_params[:type]

    # calling delete_all to be fast, I don't believe we care about callbacks in this case
    current_or_guest_user.bookmarks.where(record_type: clear_params[:type]).delete_all
    true # Returning true so this is viewed as a success
  end

  # Only permit a type param of articles or catalog
  def clear_params(controller_names: %w[article catalog])
    params.permit(:type).select { |_, val| controller_names.include? val }
  end

  def permit_bookmarks
    params.permit(bookmarks: [:document_id, :document_type, :record_type])
  end
end
