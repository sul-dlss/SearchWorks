# frozen_string_literal: true

# ArticleController is the controller for Article Search
class ArticleController < ApplicationController
  include Blacklight::Configurable

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
    config.index.title_field = :title_display
    config.index.show_link = 'title_display'
    config.index.record_display_type = 'format'

    config.add_index_field 'author_display', label: 'Author'
    config.add_index_field 'format', label: 'Format'
    config.add_index_field 'academic_journal', label: 'Journal'
    config.add_index_field 'language_facet', label: 'Language'
    config.add_index_field 'pub_date', label: 'Year'
    config.add_index_field 'pub_info', label: 'Published'
    config.add_index_field 'id'

    # solr field configuration for document/show views
    config.show.html_title = 'title_display'
    config.show.heading = 'title_display'
    config.show.display_type = 'format'
    config.show.pub_date = 'pub_date'
    config.show.pub_info = 'pub_info'
    config.show.abstract = 'abstract'
    config.show.full_text_url = 'full_text_url'
    config.show.plink = 'plink'
    config.show.route = { controller: 'article' }

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field 'title_display', label: 'Title'
    config.add_show_field 'academic_journal', label: 'Journal'
    config.add_show_field 'author_display', label: 'Author'
    config.add_show_field 'format', label: 'Format'
    config.add_show_field 'pub_date', label: 'Publication Date'
    config.add_show_field 'pub_info', label: 'Published'
    config.add_show_field 'abstract', label: 'Abstract'
    config.add_show_field 'doi', label: 'DOI', helper_method: :doi_link
  end

  def index
    (@response, _deprecated_document_list) = search_service.search_results
  end

  def show
    _deprecated_response, @document = search_service.fetch(params[:id])
  end

  def new; end

  protected

  def search_service
    eds_params = {
      'guest' => session['guest'],
      'session_token' => session['eds_session_token']
    }
    Eds::SearchService.new(blacklight_config, search_state.to_h, eds_params)
  end
end
