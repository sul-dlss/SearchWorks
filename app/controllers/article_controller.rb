# frozen_string_literal: true

# ArticleController is the controller for Article Search
class ArticleController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable

  before_action :set_search_query_modifier, only: :index

  before_action :eds_init, only: %i[index show]
  # TODO: probably need to move this into an Eds::SearchService initializer
  def eds_init
    setup_eds_session(session)
  end

  BREAKS = {
    words_connector: '<br/>',
    two_words_connector: '<br/>',
    last_word_connector: '<br/>'
  }

  configure_blacklight do |config|
    # Class for sending and receiving requests from a search index
    config.repository_class = Eds::Repository

    # solr field configuration for search results/index views
    config.index.document_presenter_class = IndexDocumentPresenter
    config.index.title_field = :eds_title
    config.index.show_link = 'eds_title'
    config.index.display_type_field = 'eds_publication_type'
    config.index.fulltext_links_field = 'eds_fulltext_links'

    # Configured index fields not used
    # config.add_index_field 'author_display', label: 'Author'
    # config.add_index_field 'id'

    config.add_search_field('search') do |field|
      field.label = 'All fields'
    end

    config.add_search_field('author') do |field|
      field.label = 'Author'
    end

    config.add_search_field('title') do |field|
      field.label = 'Article title'
    end

    config.add_search_field('subject') do |field|
      field.label = 'Subject'
    end

    config.add_search_field('source') do |field|
      field.label = 'Journal title'
    end

    config.add_search_field('abstract') do |field|
      field.label = 'Abstract'
    end

    config.add_search_field('issn') do |field|
      field.label = 'ISSN'
    end

    config.add_search_field('isbn') do |field|
      field.label = 'ISBN'
    end

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
    config.show.sections = {
      'Summary' => {
        eds_authors:              { label: 'Authors', separator_options: BREAKS },
        eds_author_affiliations:  { label: 'Author Affiliations' },
        eds_composed_title:       { label: 'Composed Title', helper_method: :render_text_from_html },
        eds_publication_date:     { label: 'Publication Date' },
        eds_languages:            { label: 'Language' }
      },
      'Abstract' => {
        eds_abstract: { label: 'Abstract', helper_method: :render_text_from_html },
        eds_notes:    { label: 'Notes' }
      },
      'Subjects' => {
        eds_subjects:                 { label: 'Subjects', separator_options: BREAKS },
        eds_subjects_geographic:      { label: 'Geography', helper_method: :render_text_from_html, seperator: '<br/>'.html_safe },
        eds_subjects_person:          { label: 'Person Subjects' },
        eds_author_supplied_keywords: { label: 'Author Supplied Keywords' }
      },
      'Details' => {
        eds_publication_type:     { label: 'Format' },
        eds_document_doi:         { label: 'DOI', helper_method: :link_to_doi },
        eds_database_name:        { label: 'Database' },
        eds_source_title:         { label: 'Journal' },
        eds_volume:               { label: 'Volume' },
        eds_series:               { label: 'Series' },
        eds_issue:                { label: 'Issue' },
        eds_page_start:           { label: 'Page Start' },
        eds_page_count:           { label: 'Page Count' },
        eds_isbns:                { label: 'ISBN' },
        eds_issns:                { label: 'ISSN' },
        eds_publication_info:     { label: 'Published' },
        eds_document_oclc:        { label: 'OCLC' },
        eds_document_type:        { label: 'Document Type' },
        eds_other_titles:         { label: 'Other Titles' },
        eds_physical_description: { label: 'Physical Description' }
      }
    }

    # Register section fields with `add_show_field` to leverage rendering pipeline
    config.show.sections.each do |_section, fields|
      fields.each do |field, options|
        config.add_show_field field.to_s, options
      end
    end

    # Facet field configuration
    config.add_facet_field 'eds_search_limiters_facet', label: 'Options'
    config.add_facet_field 'eds_publication_type_facet', label: 'Source type'
    config.add_facet_field 'eds_language_facet', label: 'Language' # , limit: 20 TODO: Need to handle facet limiting
    config.add_facet_field 'eds_subject_topic_facet', label: 'Topic'
    config.add_facet_field 'eds_subjects_geographic_facet', label: 'Geography'
    config.add_facet_field 'eds_journal_facet', label: 'Journal title'
    config.add_facet_field 'eds_publisher_facet', label: 'Publisher'
    config.add_facet_field 'eds_content_provider_facet', label: 'Database'

    # Other available facets
    # config.add_facet_field 'eds_publication_year_facet', label: 'Publication Year'
    # config.add_facet_field 'eds_category_facet', label: 'Category'
    # config.add_facet_field 'eds_library_location_facet', label: 'Library'
    # config.add_facet_field 'eds_library_collection_facet', label: 'Location'
    # config.add_facet_field 'eds_author_university_facet', label: 'University'

    # View type group config
    config.view.list.icon_class = "fa-th-list"
    config.view.brief ||= OpenStruct.new
    config.view.brief.partials = %i[index]
    config.view.brief.icon_class = "fa-align-justify"
  end

  def index
    (@response, _deprecated_document_list) = search_service.search_results
  end

  def show
    @response, @document = search_service.fetch(params[:id])
    respond_to do |format|
      format.html { setup_next_and_previous_documents }
    end
  end

  def new; end

  protected

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def search_service
    eds_params = {
      'guest' => true, # TODO: hardcoded to non-authenticated
      'session_token' => session['eds_session_token']
    }
    Eds::SearchService.new(blacklight_config, search_state.to_h, eds_params)
  end

  def set_search_query_modifier
    @search_modifier ||= SearchQueryModifier.new(params, blacklight_config)
  end

  # Reuse the EDS session token if available in the user's session data,
  # otherwise establish a session
  def setup_eds_session(session)
    return if session['eds_session_token'].present?
    session['eds_session_token'] = EBSCO::EDS::Session.new(
      guest: true, # TODO: hardcoded to non-authenticated
      caller: 'new-session',
      user: Settings.EDS_USER,
      pass: Settings.EDS_PASS,
      profile: Settings.EDS_PROFILE,
      debug: Settings.EDS_DEBUG
    ).session_token
  end
end
