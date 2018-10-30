class ArticleSelectionsController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable
  include Blacklight::SearchContext
  include Blacklight::SearchHelper
  include Blacklight::TokenBasedUser

  copy_blacklight_config_from(ArticlesController)

  before_action :verify_user

  blacklight_config.http_method = Blacklight::Engine.config.bookmarks_http_method
  blacklight_config.add_results_collection_tool(:clear_bookmarks_widget)

  blacklight_config.show.document_actions[:bookmark].if = false if blacklight_config.show.document_actions[:bookmark]
  blacklight_config.show.document_actions[:sms].if = false if blacklight_config.show.document_actions[:sms]


  def index
    @bookmarks = token_or_current_or_guest_user.bookmarks.where(record_type: 'article')
    bookmark_ids = @bookmarks.collect { |b| b.document_id.to_s }

    eds_params = {
      guest:          session['eds_guest'],
      session_token:  session['eds_session_token']
    }

    if bookmark_ids.present?
      @response, @document_list = fetch(bookmark_ids)
    else
      @document_list = []
    end

    respond_to do |format|
      format.html { render 'bookmarks/index' }
      format.rss  { render :layout => false }
      format.atom { render :layout => false }
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

  protected

  def verify_user
    unless current_or_guest_user or (action == "index" and token_or_current_or_guest_user)
      flash[:notice] = I18n.t('blacklight.bookmarks.need_login') and raise Blacklight::Exceptions::AccessDenied
    end
  end
end
