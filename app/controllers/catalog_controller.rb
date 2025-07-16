# frozen_string_literal: true

class CatalogController < ApplicationController
  include AllCapsParams

  include ReplaceSpecialQuotes

  include AdvancedSearchParamsMapping

  include FormatParamsMapping

  include Blacklight::Catalog

  include Blacklight::Marc::Catalog

  include BlacklightRangeLimit::ControllerOverride

  include CallnumberSearch

  include LocationFacet
  include NegativeFacets

  include EmailValidation
  include CatalogEmailSending

  include StanfordWorkFacet

  include SearchRelevancyLogging

  include Blacklight::Ris::Catalog
  include Blacklight::TokenBasedUser # For refworks export of multiple records

  before_action only: :index do
    if params[:page] && params[:page].to_i > Settings.PAGINATION_THRESHOLD.to_i
      flash[:error] =
        "You have paginated too deep into the result set. Please contact us using the feedback form if you have a need to view results past page #{Settings.PAGINATION_THRESHOLD}."
      redirect_to root_path
    end
  end

  before_action only: :index do
    blacklight_config.max_per_page = 10000 if params[:export]
  end

  # Upstream opensearch action doesn't handle our complex title field well.
  before_action only: :opensearch do
    blacklight_config.index.title_field = blacklight_config.index.title_field.field
  end

  # Reset the facet component to the default Blacklight ListComponent for the facet modal
  before_action only: :facet do
    next unless blacklight_config.facet_fields[params[:id]].component == Searchworks4::FacetSearchComponent

    blacklight_config.facet_fields[params[:id]].component = Blacklight::Facets::ListComponent
  end

  before_action do
    blacklight_config.default_solr_params['client-ip'] = request.remote_ip
    blacklight_config.default_solr_params['request-id'] = request.request_id || '-'
  end

  before_action BlacklightAdvancedSearch::RedirectLegacyParamsFilter, :only => :index

  before_action only: :index do
    top_filters = blacklight_config.top_filters[PageLocation.new(search_state).access_point] || blacklight_config.top_filters[:default]

    top_filters.each do |filter|
      blacklight_config.facet_fields[filter].group = 'top' if blacklight_config.facet_fields[filter].present?
    end
  end

  configure_blacklight do |config|
    config.bootstrap_version = 5
    config.add_results_document_tool(:bookmark, component: Document::TrackingBookmarkComponent, if: :render_bookmarks_control?)

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 20,
      "f.callnum_facet_hsim.facet.limit": "-1",
      "f.stanford_work_facet_hsim.facet.limit": "-1",
      "f.format_hsim.facet.limit": "-1"
    }

    config.fetch_many_document_params = { fl: '*' }

    config.search_state_fields += [
      :prefix, # used to filter by database title
    ]

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]
    config.default_per_page = 20

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.document_solr_path = 'select'
    config.json_solr_path = 'select'
    config.default_document_solr_params = {
     :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    }

    if Settings.DISABLE_SESSIONS
      config.crawler_detector = lambda { |_| true }
    end

    config.facet_search_builder_class = CustomFacetSearchBuilder

    # solr field configuration for search results/index views
    config.index.document_presenter_class = IndexDocumentPresenter
    config.index.document_component = Searchworks4::DocumentComponent
    config.index.constraints_component = Searchworks4::ConstraintsComponent
    config.index.facet_filters_component = Searchworks4::FacetFiltersComponent

    config.index.title_field = Blacklight::Configuration::IndexField.new(field: 'title_display', steps: [TitleRenderingStep])
    config.index.thumbnail_component = ThumbnailWithIiifComponent
    config.index.thumbnail_method = :render_cover_image
    config.index.mini_bento_component = SearchResult::MiniBento::CatalogComponent

    config.index.search_field_mapping = { # Catalog -> Article
      search:         :search,
      search_author:  :author,
      search_title:   :title,
      subject_terms:  :subject,
      call_number:    :search,
      search_series:  :search
    }

    # restrict available pagination options because we block deep pagination
    config.index.pagination_options = { theme: 'blacklight', left: 3, right: 0 }

    # solr field configuration for document/show views
    config.show.document_presenter_class = ShowDocumentPresenter
    config.show.document_component = Record::DocumentComponent

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    config.add_facet_field 'access_facet', label: 'Access',
                           query: {
                             'At the Library': {
                               label: 'At the Library', fq: 'access_facet:"At the Library"'
                             },
                             'Online': {
                                label: 'Online', fq: "access_facet:Online"
                             },
                             'On order': {
                                label: 'On order', fq: 'access_facet:"On order"'
                              }
                           },
                           component: Blacklight::Facets::ListComponent
    config.add_facet_field "format_hsim", label: "Format", sort: :index, component: Blacklight::Hierarchy::FacetFieldListComponent
    config.add_facet_field "library", field: "library_code_facet_ssim", label: "Library", limit: 100, sort: :index,
                            helper_method: :translate_library_code,
                            component: Searchworks4::LibraryFacetComponent
    config.add_facet_field "genre_ssim", label: "Genre", limit: 6, suggest: true,
                           component: Searchworks4::FacetSearchComponent
    config.add_facet_field "pub_year_tisim", label: "Date", range: true

    config.add_facet_field "language", label: "Language", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field "author_person_facet", label: "Author", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field "topic_facet", label: "Topic", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field "geographic_facet", label: "Region", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field 'callnum_facet_hsim',
                           label: 'Call number',
                           component: Blacklight::Hierarchy::FacetFieldListComponent,
                           sort: 'index'

    config.add_facet_field 'pub_year_adv_search', show: false, field: 'pub_year_tisim', range: true, advanced_search_component: AdvancedSearchRangeLimitComponent
    config.add_facet_field "db_az_subject", label: "Database topic", collapse: false, show: false, limit: 6, sort: :index, component: Blacklight::Facets::ListComponent
    config.add_facet_field 'location_facet', label: 'Location', collapse: false, show: false, limit: 6, component: Blacklight::Facets::ListComponent
    config.add_facet_field 'stanford_work_facet_hsim',
                           label: 'Stanford student work',
                           component: Blacklight::Hierarchy::FacetFieldListComponent,
                           sort: 'count', collapse: false, show: false
    config.add_facet_field 'stanford_dept_sim', label: 'Stanford school or department', collapse: false, show: false, limit: 6, component: Blacklight::Facets::ListComponent
    config.add_facet_field "collection", label: "Collection", show: false, helper_method: :collection_breadcrumb_value,
                            filter_query_builder: CollectionFilterQuery,
                            component: Blacklight::Facets::ListComponent
    config.add_facet_field "collection_type", label: "Collection type", show: false, component: Blacklight::Facets::ListComponent
    config.add_facet_field 'fund_facet', label: 'Acquired with support from', show: false, helper_method: :bookplate_breadcrumb_value, component: Blacklight::Facets::ListComponent,
                           item_presenter: FundFacetItemPresenter
    config.add_facet_field "format_physical_ssim", label: "Media type", limit: 6, show: false, component: Blacklight::Facets::ListComponent
    config.facet_display = {
      hierarchy: {
        'callnum_facet' => [['hsim'], '|'],
        'stanford_work_facet' => [['hsim'], '|'],
        'format' => [['hsim'], '|']
      }
    }
    # TODO: remove "course" and "instructor" after a time. These have been replaced by courses_folio_id_ssim.
    # We just don't want to break any bookmarks that people may have. Perhaps wait for a semester or so.
    config.add_facet_field "course", label: "Course", show: false, component: Blacklight::Facets::ListComponent
    config.add_facet_field "instructor", label: "Instructor", show: false, component: Blacklight::Facets::ListComponent
    config.add_facet_field "courses_folio_id_ssim", label: "Course", show: false,
                           component: Blacklight::Facets::ListComponent,
                           item_presenter: FolioCourseFacetItemPresenter

    config.add_facet_field "era_facet", label: "Era", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field "author_other_facet", label: "Organization (as author)", limit: 6, suggest: true, component: Searchworks4::FacetSearchComponent
    config.add_facet_field 'iiif_resources', label: 'IIIF resources', show: false, query: {
      available: {
        label: 'Available', fq: 'iiif_manifest_url_ssim:*'
      }
    }, component: Blacklight::Facets::ListComponent, include_in_advanced_search: false

    config.top_filters = {
      :default => ['access_facet', 'format_hsim', 'library'],
      :government_documents => ['access_facet', 'callnum_facet_hsim', 'author_other_facet'],
      :dissertation_theses => ['access_facet', 'stanford_dept_sim', 'stanford_work_facet_hsim'],
      :advanced_search => ['access_facet', 'format_hsim', 'language', 'building_facet', 'pub_year_tisim']
    }

    # Pivot facet example
    #config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    # config.add_index_field "author_person_display", label: "Author/Creator"
    # config.add_index_field "vern_author_person_display", label: "Author/Creator"
    # config.add_index_field "author_corp_display", label: "Corporate Author"
    # config.add_index_field "vern_author_corp_display", label: "Corporate Author"
    # config.add_index_field "author_meeting_display", label: "Meeting"
    # config.add_index_field "vern_author_meeting_display", label: "Meeting"
    # config.add_index_field "pub_date", label: "Date"
    # config.add_index_field "imprint_display", label: "Imprint"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    # config.add_show_field "title_full_display", label: "Title"
    # config.add_show_field "vern_title_full_display", label: "Title"
    # config.add_show_field "title_variant_display", label: "Alternate Title"
    # config.add_show_field "author_person_display", label: "Author/Creator"
    # config.add_show_field "author_person_full_display", label: "Author/Creator"
    # config.add_show_field "vern_author_person_full_display", label: "Author/Creator"
    # config.add_show_field "author_corp_display", label: "Corporate Author"
    # config.add_show_field "vern_author_corp_display", label: "Corporate Author"
    # config.add_show_field "author_meeting_display", label: "Meeting Author"
    # config.add_show_field "vern_author_meeting_display", label: "Meeting Author"
    # config.add_show_field "medium", label: "Medium"
    # config.add_show_field "summary_display", label: "Description"
    # config.add_show_field "topic_display", label: "Subject"
    # config.add_show_field "subject_other_display", label: "Subject"
    # config.add_show_field "language", label: "Language"
    # config.add_show_field "physical", label: "Physical Description"
    # config.add_show_field "pub_display", label: "Publication Info"
    # config.add_show_field "pub_date", label: "Date"

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field('search') do |field|
      field.label = 'All fields'
      field.cjk_solr_parameters = {
        qf:  '${qf_cjk}',
        pf:  '${pf_cjk}',
        pf2: '${pf2_cjk}',
        pf3: '${pf3_cjk}'
      }
    end

    config.add_search_field('search_title') do |field|
      field.label = "Title"
      field.solr_parameters = {
        qf:  '${qf_title}',
        pf:  '${pf_title}',
        pf3: '${pf3_title}',
        pf2: '${pf2_title}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_title',
        pf:  '$pf_title',
        pf3: '$pf3_title',
        pf2: '$pf2_title'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_title_cjk}',
        pf:  '${pf_title_cjk}',
        pf3: '${pf3_title_cjk}',
        pf2: '${pf2_title_cjk}'
      }
    end

    config.add_search_field('search_author') do |field|
      field.label = "Author/Contributor"
      field.solr_parameters = {
        qf:  '${qf_author}',
        pf:  '${pf_author}',
        pf3: '${pf3_author}',
        pf2: '${pf2_author}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_author',
        pf:  '$pf_author',
        pf3: '$pf3_author',
        pf2: '$pf2_author'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_author_cjk}',
        pf:  '${pf_author_cjk}',
        pf3: '${pf3_author_cjk}',
        pf2: '${pf2_author_cjk}'
      }
    end

    config.add_search_field('subject_terms') do |field|
      field.label = "Subject"
      field.solr_parameters = {
        qf:  '${qf_subject}',
        pf:  '${pf_subject}',
        pf3: '${pf3_subject}',
        pf2: '${pf2_subject}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_subject',
        pf:  '$pf_subject',
        pf3: '$pf3_subject',
        pf2: '$pf2_subject'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_subject_cjk}',
        pf:  '${pf_subject_cjk}',
        pf3: '${pf3_subject_cjk}',
        pf2: '${pf2_subject_cjk}'
      }
    end

    config.add_search_field('call_number') do |field|
      field.label = "Call number"
      field.include_in_advanced_search = false
      field.advanced_parse = false
      field.solr_parameters = { defType: 'lucene' }
      field.solr_local_parameters = {
        df: 'callnum_search'
      }
    end

    config.add_search_field('search_series') do |field|
      field.label = "Series"
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf:  '${qf_series}',
        pf:  '${pf_series}',
        pf3: '${pf3_series}',
        pf2: '${pf2_series}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_series',
        pf:  '$pf_series',
        pf3: '$pf3_series',
        pf2: '$pf2_series'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_series_cjk}',
        pf:  '${pf_series_cjk}',
        pf3: '${pf3_series_cjk}',
        pf2: '${pf2_series_cjk}'
      }
    end

    # Adds search fields for use only in BL Advanced Search
    config.add_search_field("series_search") do |field|
      field.label = "Series title"
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf:  '${qf_series}',
        pf:  '${pf_series}',
        pf3: '${pf3_series}',
        pf2: '${pf2_series}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_series',
        pf:  '$pf_series',
        pf3: '$pf3_series',
        pf2: '$pf2_series'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_series_cjk}',
        pf:  '${pf_series_cjk}',
        pf3: '${pf3_series_cjk}',
        pf2: '${pf2_series_cjk}'
      }
    end

    config.add_search_field("pub_search") do |field|
      field.label = "Place, publisher, year"
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf:  '${qf_pub_info}',
        pf:  '${pf_pub_info}',
        pf3: '${pf3_pub_info}',
        pf2: '${pf2_pub_info}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_pub_info',
        pf:  '$pf_pub_info',
        pf3: '$pf3_pub_info',
        pf2: '$pf2_pub_info'
      }
      field.cjk_solr_parameters = {
        qf:  '${qf_pub_info_cjk}',
        pf:  '${pf_pub_info_cjk}',
        pf3: '${pf3_pub_info_cjk}',
        pf2: '${pf2_pub_info_cjk}'
      }
    end

    config.add_search_field("isbn_search") do |field|
      field.label = "ISBN/ISSN etc."
      field.include_in_simple_select = false
      field.solr_parameters = {
        qf:  '${qf_number}',
        pf:  '${pf_number}',
        pf3: '${pf3_number}',
        pf2: '${pf2_number}'
      }
      field.solr_adv_parameters = {
        qf:  '$qf_number',
        pf:  '$pf_number',
        pf3: '$pf3_number',
        pf2: '$pf2_number'
      }
    end

    config.add_search_field('author_title') do |field|
      field.label = "Author + Title"
      field.include_in_simple_select = false
      field.include_in_advanced_search = false
      field.solr_parameters = {
        qf:  '${qf_author_title}',
        pf:  '${pf_author_title}',
        pf3: '${pf3_author_title}',
        pf2: '${pf2_author_title}'
      }
    end

    # Configure facet fields for BL advanced search
    config.advanced_search = Blacklight::OpenStructWithHashAccess.new(
      enabled: true,
      query_parser: 'edismax',
      url_key: 'advanced',
      form_solr_parameters: {
        "facet.field" => ["access_facet", "format_hsim", "format_physical_ssim", "library_code_facet_ssim", "language"],
         # return all facet values
        "f.access_facet.facet.limit" => -1,
        "f.format_hsim.facet.limit" => -1,
        "f.format_physical_ssim.facet.limit" => -1,
        "f.library_code_facet_ssim.facet.limit" => -1,
        "f.language.facet.limit" => -1,
        "facet.sort" => "index" # sort by byte order of values
      }
    )
    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'relevance', sort: 'score desc, pub_date_sort desc, title_sort asc', label: 'relevance'
    config.add_sort_field 'new-to-libs', sort: 'date_cataloged desc, title_sort asc', label: 'new to the Libraries'
    config.add_sort_field 'year-desc', sort: 'pub_date_sort desc, title_sort asc', label: 'year (new to old)'
    config.add_sort_field 'year-asc', sort: 'pub_date_sort asc, title_sort asc', label: 'year (old to new)'
    config.add_sort_field 'author', sort: 'author_sort asc, title_sort asc', label: 'author'
    config.add_sort_field 'title', sort: 'title_sort asc, pub_date_sort desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # View type group config
    config.view.list.icon = Searchworks::Icons::ListIcon
    config.view.gallery(icon: Searchworks::Icons::GalleryIcon, document_component: SearchResult::DocumentGalleryComponent)

    config.index.respond_to.mobile = true
    config.fetch_many_document_params = { qt: 'document' }

    config.add_show_tools_partial :citation, if: false
    config.add_show_tools_partial :email, callback: :send_emails_to_all_recipients, validator: :validate_email_params_and_recaptcha
    config.add_show_tools_partial :sms, if: false, callback: :sms_action, validator: :validate_sms_params
  end

  # Overridden from Blacklight
  def citation
    @documents = search_service.fetch(Array(params[:id]))
  end

  def stackmap
    @document = search_service.fetch(params[:id])
    @items = @document.holdings.items.select { |item| item.effective_permanent_location_code == params[:location] }
    library_code = @items.first.library
    location = @document.holdings.libraries.find { |library| library.code == library_code }.locations.find { |location| location.code == params[:location] }
    @stackmap_api_url = location.stackmap_api_url
    render layout: !request.xhr?
  end

  def facet_results
    @facet = blacklight_config.facet_fields[params[:id]]

    @response = facet_search_service.facet_suggest_response(@facet.key, params[:query_fragment], "f.#{@facet.key}.facet.method" => 'fc')

    @display_facet = @response.aggregations[@facet.field]
    @presenter = @facet.presenter.new(@facet, @display_facet, view_context)

    respond_to do |format|
      format.html { render layout: false }
    end
  end

  private

  def augment_solr_document_json_response(documents)
    documents.map do |document|
      JsonResultsDocumentPresenter.new(document)
    end
  end
  helper_method :augment_solr_document_json_response

  def advanced_search_form?(*args, **kwargs)
    action_name == 'advanced_search'
  end
end
