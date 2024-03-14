# frozen_string_literal: true

class ArticleSelectionsController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable
  include Blacklight::SearchContext
  include Blacklight::Searchable
  include Blacklight::TokenBasedUser
  include SelectionsCount

  copy_blacklight_config_from(ArticlesController)

  before_action :verify_user

  blacklight_config.http_method = Blacklight::Engine.config.blacklight.bookmarks_http_method
  blacklight_config.add_results_collection_tool(:clear_bookmarks_widget)

  blacklight_config.show.document_actions[:bookmark].if = false if blacklight_config.show.document_actions[:bookmark]
  blacklight_config.show.document_actions[:sms].if = false if blacklight_config.show.document_actions[:sms]

  def index
    @bookmarks = paged_bookmarks
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }

    if bookmark_ids.present?
      @response, @document_list = search_service.fetch(bookmark_ids)
    else
      @document_list = []
    end

    @catalog_count = selections_counts.catalog
    @article_count = selections_counts.articles

    respond_to do |format|
      format.html { render 'bookmarks/index' }
      format.rss  { render layout: false }
      format.atom { render layout: false }
      format.json do
        render json: render_search_results_as_json
      end

      additional_response_formats(format)
      document_export_formats(format)
    end
  end

  def _prefixes
    @_prefixes ||= super + ['articles', 'catalog']
  end

  # Overridden Blacklight helper method to generate a "start"
  # for bookmarks similar to what the solr response provides
  def document_counter_with_offset idx, offset = nil
    offset ||= ((@bookmarks.current_page - 1) * @bookmarks.limit_value) if @bookmarks
    offset ||= 0

    idx + 1 + offset
  end
  helper_method :document_counter_with_offset

  protected

  def paged_bookmarks
    token_or_current_or_guest_user
      .bookmarks.where(record_type: 'article')
      .page(params[:page])
      .per(params[:per_page] || 20)
  end

  def verify_user
    unless current_or_guest_user or (action == "index" and token_or_current_or_guest_user)
      flash[:notice] = I18n.t('blacklight.bookmarks.need_login') and raise Blacklight::Exceptions::AccessDenied
    end
  end
end
