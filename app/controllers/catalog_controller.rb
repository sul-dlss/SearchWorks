# -*- encoding : utf-8 -*-
#
class CatalogController < ApplicationController

  include Blacklight::Marc::Catalog

  include Blacklight::Catalog

  include AdvancedSearchParamsMapping

  include DatabaseAccessPoint

  include CallnumberSearch

  include AllCapsParams

  include ReplaceSpecialQuotes

  include CJKQuery

  include Thumbnail

  helper Openseadragon::OpenseadragonHelper

  before_filter :add_show_partials
  before_filter :set_search_query_modifier, only: :index

  before_action only: :index do
    if params[:page] && params[:page].to_i > Settings.PAGINATION_THRESHOLD.to_i
      flash[:error] = "You have paginated too deep into the result set. Please contact us using the feedback form if you have a need to view results past page #{Settings.PAGINATION_THRESHOLD}."
      redirect_to root_path
    end
  end

  configure_blacklight do |config|
    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      :qt => 'search',
      :rows => 20,
      :"f.callnum_facet_hsim.facet.limit" => "-1"
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]
    config.default_per_page = 20


    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    #config.default_document_solr_params = {
    #  :qt => 'document',
    #  ## These are hard-coded in the blacklight 'document' requestHandler
    #  # :fl => '*',
    #  # :rows => 1
    #  # :q => '{!raw f=id v=$id}'
    #}

    # solr field configuration for search results/index views
    config.index.title_field = 'title_display'
    config.index.display_type_field = 'format'
    config.index.thumbnail_method = :thumbnail

    # solr field configuration for document/show views
    #config.show.title_field = 'title_display'
    #config.show.display_type_field = 'format'

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
    config.add_facet_field "db_az_subject", :label => "Database topic", collapse: false, show: false, limit: 20
    config.add_facet_field "access_facet", :label => "Access", limit: 10
    config.add_facet_field "collection", label: "Collection", show: false, helper_method: :collection_breadcrumb_value
    config.add_facet_field "collection_type", :label => "Collection type", :show => false
    if Settings.BOOKPLATES
      config.add_facet_field 'fund_facet', label: 'Bookplate', show: false, helper_method: :bookplate_breadcrumb_value
    end
    config.add_facet_field "format_main_ssim", :label => "Resource type", partial: "resource_type_facet", limit: 100, sort: :index
    config.add_facet_field "format_physical_ssim", :label => "Media type", limit: 20
    config.add_facet_field "pub_year_tisim", :label => "Date", :range => {
      :input_label_range_begin => "from year",
      :input_label_range_end => "to year"
    }
    config.add_facet_field "building_facet", :label => "Library", limit: 100, sort: :index
    config.add_facet_field "language", :label => "Language", limit: 20
    config.add_facet_field "author_person_facet", :label => "Author", limit: 20
    config.add_facet_field 'callnum_facet_hsim',
                           label: 'Call number',
                           partial: 'blacklight/hierarchy/facet_hierarchy',
                           sort: 'index'
    config.facet_display = {
      :hierarchy => {
        'callnum_facet' => [['hsim'], '|']
      }
    }
    config.add_facet_field "topic_facet", :label => "Topic", limit: 20
    config.add_facet_field "genre_ssim", :label => "Genre", limit: 20
    config.add_facet_field "course", :label => "Course", :show => false
    config.add_facet_field "instructor", :label => "Instructor", :show => false

    # Should be shown under the "more..." section see https://github.com/sul-dlss/SearchWorks/issues/257
    config.add_facet_field "geographic_facet", :label => "Region", limit: 20
    config.add_facet_field "era_facet", :label => "Era", limit: 20
    config.add_facet_field "author_other_facet", :label => "Organization (as author)", limit: 20
    config.add_facet_field "format", :label => "Format", show: false

    # Pivot facet example
    #config.add_facet_field 'example_pivot_field', :label => 'Pivot Field', :pivot => ['format', 'language_facet']


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field "author_person_display", :label => "Author/Creator"
    config.add_index_field "vern_author_person_display", :label => "Author/Creator"
    config.add_index_field "author_corp_display", :label => "Corporate Author"
    config.add_index_field "vern_author_corp_display", :label => "Corporate Author"
    config.add_index_field "author_meeting_display", :label => "Meeting"
    config.add_index_field "vern_author_meeting_display", :label => "Meeting"
    config.add_index_field "pub_date", :label => "Date"
    config.add_index_field "imprint_display", :label => "Imprint"

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field "title_full_display", :label => "Title"
    config.add_show_field "vern_title_full_display", :label => "Title"
    config.add_show_field "vern_title_uniform_display", :label => "Uniform Title"
    config.add_show_field "title_variant_display", :label => "Alternate Title"
    config.add_show_field "author_person_display", :label => "Author/Creator"
    config.add_show_field "author_person_full_display", :label => "Author/Creator"
    config.add_show_field "vern_author_person_full_display", :label => "Author/Creator"
    config.add_show_field "author_corp_display", :label => "Corporate Author"
    config.add_show_field "vern_author_corp_display", :label => "Corporate Author"
    config.add_show_field "author_meeting_display", :label => "Meeting Author"
    config.add_show_field "vern_author_meeting_display", :label => "Meeting Author"
    config.add_show_field "medium", :label => "Medium"
    config.add_show_field "summary_display", :label => "Description"
    config.add_show_field "topic_display", :label => "Subject"
    config.add_show_field "subject_other_display", :label => "Subject"
    config.add_show_field "language", :label => "Language"
    config.add_show_field "physical", :label => "Physical Description"
    config.add_show_field "pub_display", :label => "Publication Info"
    config.add_show_field "pub_date", :label => "Date"

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

    config.add_search_field("search") do |field|
      field.label = "All fields"
      field.solr_local_parameters = {
        :pf2 => "$p2",
        :pf3 => "$pf3"
      }
    end

    config.add_search_field('search_title') do |field|
      field.label = "Title"
      field.solr_local_parameters = {
        :qf  => '$qf_title',
        :pf  => '$pf_title',
        :pf3 => "$pf3_title",
        :pf2 => "$pf2_title"
      }
    end

    config.add_search_field('search_author') do |field|
      field.label = "Author/Contributor"
      field.solr_local_parameters = {
        :qf  => '$qf_author',
        :pf  => '$pf_author',
        :pf3 => "$pf3_author",
        :pf2 => "$pf2_author"
      }
    end

    config.add_search_field('subject_terms') do |field|
      field.label = "Subject"
      field.solr_local_parameters = {
        :qf  => '$qf_subject',
        :pf  => '$pf_subject',
        :pf3 => "$pf3_subject",
        :pf2 => "$pf2_subject"
      }
    end

    config.add_search_field('call_number') do |field|
      field.label = "Call number"
      field.include_in_advanced_search = false
      field.solr_parameters = { :defType => "lucene"}
      field.solr_local_parameters = {
        :df => 'callnum_search'
      }
    end

    config.add_search_field('search_series') do |field|
      field.label = "Series"
      field.include_in_advanced_search = false
      field.solr_local_parameters = {
        :qf  => '$qf_series',
        :pf  => '$pf_series',
        :pf3 => "$pf3_series",
        :pf2 => "$pf2_series"
      }
    end

    # Adds search fields for use only in BL Advanced Search
    config.add_search_field("series_search") do |field|
      field.label = "Series title"
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf  => '$qf_series',
        :pf  => '$pf_series',
        :pf3 => "$pf3_series",
        :pf2 => "$pf2_series"
      }
    end

    config.add_search_field("pub_search") do |field|
      field.label = "Place, publisher, year"
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf  => "$qf_pub_info",
        :pf  => "$pf_pub_info",
        :pf3 => "$pf3_pub_info",
        :pf2 => "$pf2_pub_info"
      }
    end

    config.add_search_field("isbn_search") do |field|
      field.label = "ISBN/ISSN etc."
      field.include_in_simple_select = false
      field.solr_local_parameters = {
        :qf  => "$qf_number",
        :pf  => "$pf_number",
        :pf3 => "$pf3_number",
        :pf2 => "$pf2_number"
      }
    end

    config.add_search_field('author_title') do |field|
      field.label = "Author + Title"
      field.include_in_simple_select = false
      field.include_in_advanced_search = false
      field.solr_local_parameters = {
        :qf  => 'author_title_search',
        :pf  => 'author_title_search^10',
        :pf3 => 'author_title_search^5',
        :pf2 => 'author_title_search^2'
      }
    end

    # Configure facet fields for BL advanced search
    config.advanced_search = {
      :query_parser => 'edismax',
      :form_solr_parameters => {
        "facet.field" => ["access_facet", "format_main_ssim", "format_physical_ssim", "building_facet", "language"],
        "facet.limit" => -1, # return all facet values
        "facet.sort" => "index" # sort by byte order of values
      }
    }
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

    # Deletes slideshow view
    config.view.delete_field("slideshow")

    # View type group config
    config.view.list.icon_class = "fa-th-list"

    config.view.gallery.partials = [:index]
    config.view.gallery.icon_class = "fa-th"

    config.view.brief.partials = [:index]
    config.view.brief.icon_class = "fa-align-justify"

    config.index.respond_to.mobile = true
  end

  # Overridden from Blacklight to take a type parameter and render different a full or brief version of the record.
  # Email Action (this will render the appropriate view on GET requests and process the form and send the email on POST requests)
  def email
    @response, @documents = get_solr_response_for_document_ids(params[:id])

    if request.post? and validate_email_params
      email_params = {to: params[:to], message: params[:message], subject: params[:subject]}
      email = if params[:type] == "full"
        SearchWorksRecordMailer.full_email_record(@documents, email_params, url_options)
      else
        SearchWorksRecordMailer.email_record(@documents, email_params, url_options)
      end
      email.deliver

      flash[:success] = I18n.t("blacklight.email.success")

      respond_to do |format|
        format.html { redirect_to catalog_path(params['id']) }
        format.js { render 'email_success' }
      end and return
    end

    respond_to do |format|
      format.html
      format.js { render :layout => false }
    end
  end

  def backend_lookup
    (@response, @document_list) = get_search_results
    respond_to do |format|
      format.json { render json: render_search_results_as_json }
      format.html { render 'public/500', layout: false, status: 400 }
    end
  end

  def availability
    _, documents = get_solr_response_for_document_ids(params[:id])
    respond_to do |format|
      format.json do
        render json: render_document_with_availability_as_json(documents.first)
      end
      format.html { render 'public/500', layout: false, status: 400 }
    end
  end

  def stackmap
    render layout: !request.xhr?
  end

  private

  def render_document_with_availability_as_json(document = nil)
    return {} unless document.is_a?(SolrDocument)
    {
      title: document[blacklight_config.index.title_field],
      online: document.index_links.fulltext.map(&:href),
      format: document[document.format_key],
      holdings: document.holdings.as_json
    }
  end

  def validate_email_params
    unless ['full', 'brief'].include?(params[:type])
      flash[:error] = "Invalid email type provided"
    end
    if params[:email_address].present?
      flash[:error] = "You have filled in a field that makes you appear as a spammer.  Please follow the directions for the individual form fields."
    end
    if params[:message] =~ /.*href=.*|.*url=.*|.*http:\/\/.*|.*https:\/\/.*/i
      flash[:error] = "Your message appears to be spam, and has not been sent. Please try sending your message again without any links in the comments."
    end
    super
  end

  def modifiable_params_keys
    %w[q search search_author search_title subject_terms series_search pub_search isbn_search]
  end

  def set_search_query_modifier
    @search_modifier ||= SearchQueryModifier.new(params, blacklight_config)
  end

  def add_show_partials
    blacklight_config.show.partials += ["record/record_metadata"]
  end

end
