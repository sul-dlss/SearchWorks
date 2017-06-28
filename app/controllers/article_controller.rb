# frozen_string_literal: true

# ArticleController is the controller for Article Search
class ArticleController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable

  before_action :set_search_query_modifier, only: :index

  before_action :eds_init, only: %i[index show]
  # TODO: probably need to move this into an Eds::SearchService initializer
  def eds_init
    session['guest'] = true # TODO: hardcoded to non-authenticated
    session['eds_session_token'] =
      EBSCO::EDS::Session.new(
        guest: true, # TODO: hardcoded to non-authenticated
        caller: 'new-session',
        user: Settings.EDS_USER,
        pass: Settings.EDS_PASS,
        profile: Settings.EDS_PROFILE,
        debug: Settings.EDS_DEBUG
      ).session_token
  end

  configure_blacklight do |config|
    # Class for sending and receiving requests from a search index
    config.repository_class = Eds::Repository

    # solr field configuration for search results/index views
    config.index.document_presenter_class = IndexDocumentPresenter
    config.index.title_field = :eds_title
    config.index.show_link = 'eds_title'
    config.index.display_type_field = 'eds_publication_type'
    config.index.document_actions = [] # Uncomment to add bookmark toggles to results

    # Configured index fields not used
    # config.add_index_field 'author_display', label: 'Author'
    # config.add_index_field 'id'

    # solr field configuration for document/show views
    config.show.document_presenter_class = ShowDocumentPresenter
    config.show.html_title = 'eds_title'
    config.show.heading = 'eds_title'
    config.show.display_type = 'format'
    config.show.pub_date = 'eds_publication_date'
    config.show.pub_info = 'eds_publisher_info'
    config.show.abstract = 'eds_abstract'
    config.show.plink = 'eds_plink'
    config.show.route = { controller: 'article' }

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'eds_title', label: 'Title'
    config.add_show_field 'eds_languages', label: 'Language'
    config.add_show_field 'eds_physical_description', label: 'Physical Description'
    config.add_show_field 'eds_source_title', label: 'Journal'
    config.add_show_field 'eds_database_name', label: 'Database'
    config.add_show_field 'eds_authors', label: 'Author'
    config.add_show_field 'eds_publication_type', label: 'Format'
    config.add_show_field 'eds_publication_date', label: 'Publication Date'
    config.add_show_field 'eds_publisher_info', label: 'Published'
    config.add_show_field 'eds_abstract', label: 'Abstract'
    config.add_show_field 'eds_subjects', label: 'Subjects'
    config.add_show_field 'eds_document_doi', label: 'DOI', helper_method: :doi_link
  end

  def index
    (@response, _deprecated_document_list) = search_service.search_results
  end

  def show
    _deprecated_response, @document = search_service.fetch(params[:id])
  end

  def new; end

  protected

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def search_service
    eds_params = {
      'guest' => session['guest'],
      'session_token' => session['eds_session_token']
    }
    Eds::SearchService.new(blacklight_config, search_state.to_h, eds_params)
  end

  def set_search_query_modifier
    @search_modifier ||= SearchQueryModifier.new(params, blacklight_config)
  end
end
