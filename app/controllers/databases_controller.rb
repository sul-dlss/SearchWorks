# frozen_string_literal: true

class DatabasesController < ApplicationController
  layout 'searchworks4'

  def self.local_prefixes
    super + ['catalog']
  end

  include Blacklight::Catalog
  include EmailValidation
  include CatalogEmailSending

  before_action only: :index do
    if params[:page] && params[:page].to_i > Settings.PAGINATION_THRESHOLD.to_i
      flash[:error] =
        "You have paginated too deep into the result set. Please contact us using the feedback form if you have a need to view results past page #{Settings.PAGINATION_THRESHOLD}."
      redirect_to root_path
    end
  end

  # Upstream opensearch action doesn't handle our complex title field well.
  before_action only: :opensearch do
    blacklight_config.index.title_field = blacklight_config.index.title_field.field
  end

  before_action do
    blacklight_config.default_solr_params['client-ip'] = request.remote_ip
    blacklight_config.default_solr_params['request-id'] = request.request_id || '-'
  end

  configure_blacklight do |config|
    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    ## Default parameters to send to solr for all search-like requests. See also SolrHelper#solr_search_params
    config.default_solr_params = {
      qt: 'search',
      rows: 20,
      fq: ['format_main_ssim:Database'],
      'f.callnum_facet_hsim.facet.limit': "-1",
      'f.stanford_work_facet_hsim.facet.limit': "-1"
    }

    config.fetch_many_document_params = { fl: '*' }

    # items to show per page, each number in the array represent another option to choose from.
    # config.per_page = [10,20,50,100]
    config.default_per_page = 20

    ## Default parameters to send on single-document requests to Solr. These settings are the Blackligt defaults (see SolrHelper#solr_doc_params) or
    ## parameters included in the Blacklight-jetty document requestHandler.
    #
    config.document_solr_path = 'select'
    config.json_solr_path = 'select'
    config.default_document_solr_params = {
      qt: 'document'
      #  ## These are hard-coded in the blacklight 'document' requestHandler
      #  # :fl => '*',
      #  # :rows => 1
      #  # :q => '{!raw f=id v=$id}'
    }

    config.crawler_detector = ->(_) { true } if Settings.DISABLE_SESSIONS

    # solr field configuration for search results/index views
    config.index.document_presenter_class = IndexDocumentPresenter
    config.index.document_component = Searchworks4::DocumentComponent
    config.index.title_component = SearchResult::DocumentTitleComponent
    config.index.constraints_component = Searchworks4::ConstraintsComponent

    config.index.title_field = Blacklight::Configuration::IndexField.new(field: 'title_display', steps: [TitleRenderingStep])
    config.index.display_type_field = 'format_main_ssim'
    config.index.thumbnail_component = ThumbnailWithIiifComponent
    config.index.thumbnail_method = :render_cover_image

    # restrict available pagination options because we block deep pagination
    config.index.pagination_options = { theme: 'blacklight', left: 3, right: 0 }

    # solr field configuration for document/show views
    config.show.document_presenter_class = ShowDocumentPresenter
    config.show.document_component = Record::DocumentComponent
    config.show.title_component = Record::DocumentTitleComponent

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
        qf: '${qf_cjk}',
        pf: '${pf_cjk}',
        pf2: '${pf2_cjk}',
        pf3: '${pf3_cjk}'
      }
    end

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

    config.index.respond_to.mobile = true
    config.fetch_many_document_params = { qt: 'document' }

    config.add_show_tools_partial :citation, if: false
    config.add_show_tools_partial :email, callback: :send_emails_to_all_recipients, validator: :validate_email_params_and_recaptcha
    config.add_show_tools_partial :sms, if: false, callback: :sms_action, validator: :validate_sms_params
  end
end
