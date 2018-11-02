# frozen_string_literal: true

class BookmarksController < CatalogController
  include Blacklight::Bookmarks
  include SelectionsCount

  # Overidden from Blacklight to add our tabbed interface
  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks.where(record_type: 'catalog')
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }

    @response, @document_list = fetch(bookmark_ids)

    @catalog_count = selections_counts.catalog
    @article_count = selections_counts.articles

    respond_to do |format|
      format.html { }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def clear
    if current_or_guest_user.bookmarks.clear
      flash[:success] = I18n.t('blacklight.bookmarks.clear.success')
    else
      flash[:error] = I18n.t('blacklight.bookmarks.clear.failure')
    end
    redirect_back fallback_location: bookmarks_url
  end
end
