# frozen_string_literal: true

# ArticleController is the controller for Article Search
class ArticlesController < ApplicationController
  include Blacklight::Catalog
  include Blacklight::Configurable
  include EmailValidation
  include BackendLookup

  rescue_from 'EBSCO::EDS::BadRequest' do |exception|
    raise exception if params[:q].present?
    raise ActionController::RoutingError, 'Not Found' if params[:action] == 'show'

    flash[:alert] = 'An empty search is not possible in articles+. Enter a keyword to start your search.'
    redirect_back fallback_location: articles_path
  end

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

  Blacklight::ActionBuilder.new(self, :citation, {}).build

  configure_blacklight do |config|
    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    # Class for sending and receiving requests from a search index
    config.repository_class = Eds::Repository
    config.search_builder_class = ArticleSearchBuilder
    config.default_per_page = 20

    # solr field configuration for search results/index views
    config.index.document_presenter_class = IndexEdsDocumentPresenter
    config.index.facet_group_component = Articles::Response::FacetGroupComponent
    config.index.title_field = :eds_title
    config.index.show_link = 'eds_title'
    config.index.display_type_field = 'eds_publication_type'
    config.index.fulltext_links_field = 'eds_fulltext_links'
    config.index.search_field_mapping = { # Article -> Catalog
      search:   :search,
      author:   :search_author,
      title:    :search_title,
      subject:  :subject_terms,
      source:   :search_title
    }
    config.add_index_field "eds_authors", label: 'Authors', helper_method: :strip_author_relators
    config.add_index_field "eds_composed_title", label: 'Source', helper_method: :italicize_composed_title
    config.add_index_field "eds_subjects", label: 'Subjects'
    config.add_index_field "eds_abstract", label: 'Abstract', helper_method: :mark_html_safe

    config.add_search_field('search') do |field|
      field.label = 'All fields'
    end

    config.add_search_field('author') do |field|
      field.label = 'Author'
    end

    config.add_search_field('title') do |field|
      field.label = 'Title'
    end

    config.add_search_field('subject') do |field|
      field.label = 'Subject'
    end

    config.add_search_field('source') do |field|
      field.label = 'Journal/Source'
    end

    # Additional "subject"-based searches as EDS uses multiple field codes
    config.add_search_field('subject_heading') do |field| # SH field code
      field.label = 'Keyword'
      field.include_in_simple_select = false
    end

    config.add_search_field('descriptor') do |field| # DE field code
      field.label = 'Keyword'
      field.include_in_simple_select = false
    end

    config.add_search_field('keyword') do |field| # KW field code
      field.label = 'Keyword'
      field.include_in_simple_select = false
    end

    # solr field configuration for document/show views
    config.show.document_presenter_class = ShowEdsDocumentPresenter
    config.show.html_title = 'eds_title'
    config.show.heading = 'eds_title'
    config.show.display_type_field = 'eds_publication_type'
    config.show.pub_date = 'eds_publication_date'
    config.show.pub_info = 'eds_publisher_info'
    config.show.abstract = 'eds_abstract'
    config.show.plink = 'eds_plink'
    config.show.route = { controller: 'articles' }
    config.show.sections = {
      'Fulltext' => {
        eds_html_fulltext: { label: 'Full Text', helper_method: :sanitize_fulltext }
      },
      'Summary' => {
        eds_authors:              { label: 'Authors', separator_options: BREAKS, helper_method: :link_authors },
        eds_author_affiliations:  { label: 'Author Affiliations', separator_options: BREAKS, helper_method: :clean_affiliations },
        eds_composed_title:       { label: 'Source', helper_method: :italicize_composed_title },
        eds_publication_date:     { label: 'Publication Date' },
        eds_languages:            { label: 'Language', helper_method: :mark_html_safe }
      },
      'Abstract' => {
        eds_abstract: { label: 'Abstract', helper_method: :mark_html_safe },
        eds_notes:    { label: 'Notes' }
      },
      'Subjects' => {
        eds_subjects:                 { label: 'Subjects', separator_options: BREAKS, helper_method: :link_subjects },
        eds_subjects_geographic:      { label: 'Geography', separator_options: BREAKS, helper_method: :link_subjects },
        eds_subjects_person:          { label: 'Person Subjects', separator_options: BREAKS, helper_method: :link_subjects },
        eds_author_supplied_keywords: { label: 'Author Supplied Keywords', separator_options: BREAKS, helper_method: :link_subjects }
      },
      'Details' => {
        eds_publication_type:     { label: 'Format' },
        eds_document_doi:         { label: 'DOI', helper_method: :link_to_doi },
        eds_database_name:        { label: 'Database' },
        eds_source_title:         { label: 'Journal' },
        eds_volume:               { label: 'Volume' },
        eds_series:               { label: 'Series', helper_method: :remove_html_from_document_field },
        eds_issue:                { label: 'Issue' },
        eds_page_start:           { label: 'Page Start' },
        eds_page_count:           { label: 'Page Count' },
        eds_isbns:                { label: 'ISBN' },
        eds_issns:                { label: 'ISSN' },
        eds_publisher:            { label: 'Publisher' },
        eds_publication_info:     { label: 'Published' },
        eds_publication_status:   { label: 'Publication Status' },
        eds_document_oclc:        { label: 'OCLC' },
        eds_document_type:        { label: 'Document Type', helper_method: :remove_html_from_document_field },
        eds_other_titles:         { label: 'Other Titles' },
        eds_physical_description: { label: 'Physical Description' }
      }
    }

    # Register section fields with show/index presenters to leverage rendering pipeline
    config.show.sections.each_value do |fields|
      fields.each do |field, options|
        config.add_show_field field.to_s, options
      end
    end

    # Facet field configuration
    # Setting `if: false` for the limiters facet so the facet does not render as
    # a facet but we still can apploy our configured label to the breadcrumbs
    config.add_facet_field 'eds_search_limiters_facet', label: 'Settings', if: false
    config.add_facet_field 'pub_year_tisim', label: 'Date', component: ArticlesRangeLimitComponent, range: true
    config.add_facet_field 'eds_publication_type_facet', label: 'Source type', component: AdditionalSelectionsFacetComponent
    config.add_facet_field 'eds_language_facet', label: 'Language', component: Blacklight::FacetFieldListComponent # , limit: 20 TODO: Need to handle facet limiting
    config.add_facet_field 'eds_subject_topic_facet', label: 'Topic', component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'eds_subjects_geographic_facet', label: 'Geography', component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'eds_journal_facet', label: 'Journal title', component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'eds_publisher_facet', label: 'Publisher', component: Blacklight::FacetFieldListComponent
    config.add_facet_field 'eds_content_provider_facet', label: 'Database', component: AdditionalSelectionsFacetComponent

    # Other available facets
    # config.add_facet_field 'eds_publication_year_facet', label: 'Publication Year'
    # config.add_facet_field 'eds_category_facet', label: 'Category'
    # config.add_facet_field 'eds_library_location_facet', label: 'Library'
    # config.add_facet_field 'eds_library_collection_facet', label: 'Location'
    # config.add_facet_field 'eds_author_university_facet', label: 'University'

    # View type group config
    config.view.list.icon_class = "fa-th-list"
    config.view.brief(partials: %i[index], icon_class: "fa-align-justify")

    # Sorting, using EDS sort keys
    config.add_sort_field 'relevance', sort: 'score desc', label: 'relevance'
    config.add_sort_field 'newest', sort: 'newest', label: 'date (most recent)'
    config.add_sort_field 'oldest', sort: 'oldest', label: 'date (oldest)'
  end

  def fulltext_link
    _response, document = search_service.fetch(params[:id])
    url = extract_fulltext_link(document, params[:type])
    redirect_to url, allow_other_host: true if url.present?
  rescue => e
    if current_user
      # We only care if there's a user, otherwise it's definitely a data problem?
      context = current_user.to_honeybadger_context.merge(eds_guest: session['eds_guest'], eds_session_token: session['eds_session_token'])
      Honeybadger.notify(e, context:)
    end

    flash[:error] = flash_message_for_link_error
    redirect_back fallback_location: articles_path
  end

  # Used by default Blacklight `index` and `show` actions
  delegate :search_results, :fetch, to: :search_service

  def email
    # TODO: Handle arrays of IDs in future selection work
    @response, @documents = fetch(params[:id])
    @documents = Array.wrap(@documents)
    if request.post? && validate_email_params_and_recaptcha
      send_emails_to_all_recipients

      respond_to do |format|
        format.html { render 'email_success', layout: !request.xhr? }
      end and return
    end

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  protected

  def send_emails_to_all_recipients
    documents = Array.wrap(@documents)
    email_params = { message: params[:message], subject: params[:subject], email_from: params[:email_from] }
    email_addresses.each do |email_address|
      email_params[:to] = email_address
      email = if params[:type] == 'full'
                SearchWorksRecordMailer.article_full_email_record(documents, email_params, url_options)
              else
                SearchWorksRecordMailer.article_email_record(documents, email_params, url_options)
              end
      email.deliver_now
    end

    flash[:success] = I18n.t('blacklight.email.success')
  end

  def _prefixes
    @_prefixes ||= super + ['catalog']
  end

  def search_service
    eds_params = {
      guest:          session['eds_guest'],
      session_token:  session['eds_session_token']
    }
    Eds::SearchService.new(blacklight_config, params, eds_params)
  end

  def set_search_query_modifier
    @search_modifier ||= SearchQueryModifier.new(search_state)
  end

  # Reuse the EDS session token if available in the user's session data,
  # otherwise establish a session
  def setup_eds_session(session)
    return if session['eds_session_token'].present?

    session['eds_guest'] = !on_campus_or_su_affiliated_user?

    session['eds_session_token'] = Eds::Session.new(
      guest: session['eds_guest'],
      caller: 'new-session'
    ).session_token

    if current_user
      Honeybadger.add_breadcrumb('Established EDS session', metadata: {
        eds_guest: session['eds_guest'],
        eds_session_token: session['eds_session_token'],
        request_ip: request.remote_ip,
        affiliations: current_user.affiliations,
        person_affiliations: current_user.person_affiliations
      })
    end
  end

  def has_search_parameters?
    params[:q].present? || params[:f].present?
  end

  def extract_fulltext_link(document, type)
    links = document.fetch('eds_fulltext_links', [])
    links.each do |link|
      next if link['url'].blank? || link['url'] == 'detail'
      return link['url'] if link['type'] == type.to_s
    end
    raise ArgumentError, "Missing #{type} fulltext link in document #{document.id}"
  end

  def flash_message_for_link_error
    base_key = 'searchworks.articles.flashes.fulltext_link'
    return I18n.t("#{base_key}.guest_html") if session['eds_guest']

    I18n.t("#{base_key}.non_guest_html")
  end
end
