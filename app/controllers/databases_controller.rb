# frozen_string_literal: true

class DatabasesController < ApplicationController
  def self.local_prefixes
    super + ['catalog']
  end

  include Blacklight::Catalog
  include EmailValidation
  include CatalogEmailSending

  copy_blacklight_config_from(CatalogController)

  configure_blacklight do |config|
    config.facet_fields.delete_if { |k, _v| k != 'db_az_subject' }
    config.facet_fields['db_az_subject'].show = false
    config.search_fields.clear
    config.add_search_field('search')
    config.view.delete(:gallery)

    config.default_solr_params[:fq] = ['format_hsim:Database']
  end

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

  before_action only: :index do
    ids = Settings.selected_databases.keys.map(&:to_s)
    @selected_databases = search_service.fetch(ids, { sort: "title_sort asc", rows: ids.length }).sort_by { |doc| ids.index(doc.id) }
  end

  class DatabaseTitleSuggestionsSearchBuilder < Blacklight::SearchBuilder
    def self.default_processor_chain
      [:suggestion_query]
    end

    def suggestion_query(solr_parameters)
      blacklight_config.default_solr_params.each do |key, value|
        solr_parameters[key] = value.dup
      end
      solr_parameters[:qt] = 'search'
      solr_parameters[:q] = "#{search_state.query_param}*"
      solr_parameters[:qf] = 'title_245a_ws_search^170 title_245a_unstem_search^130 title_245_unstem_search^75 title_245_search^50'
      solr_parameters[:facet] = 'false'
      solr_parameters[:rows] = 10
      solr_parameters[:fl] = 'id, title_display'
    end
  end

  class DatabaseSubjectSuggestionsSearchBuilder < Blacklight::SearchBuilder
    def self.default_processor_chain
      [:suggestion_query]
    end

    def suggestion_query(solr_parameters)
      blacklight_config.default_solr_params.each do |key, value|
        solr_parameters[key] = value.dup
      end
      solr_parameters[:qt] = 'search'
      solr_parameters[:q] = '*:*'
      solr_parameters[:facet] = 'true'
      solr_parameters['facet.field'] = 'db_az_subject'
      solr_parameters['f.db_az_subject.facet.method'] = 'fc'
      solr_parameters['f.db_az_subject.facet.contains'] = search_state.query_param
      solr_parameters['f.db_az_subject.facet.contains.ignoreCase'] = 'true'
      solr_parameters[:rows] = 0
    end
  end

  def index
    if has_search_parameters?
      super
    else
      render 'home_page'
    end
  end

  def autocomplete_title_search_service
    search_service_class.new(config: blacklight_config, search_state: search_state, search_builder_class: DatabaseTitleSuggestionsSearchBuilder, **search_service_context)
  end

  def autocomplete_subject_search_service
    search_service_class.new(config: blacklight_config, search_state: search_state, search_builder_class: DatabaseSubjectSuggestionsSearchBuilder, **search_service_context)
  end

  # Autocomplete action for database suggestions.
  # This is used by the database search bar component.
  def autocomplete
    @query = search_state.query_param
    @title_response = autocomplete_title_search_service.search_results
    @facet_response = autocomplete_subject_search_service.search_results

    render layout: false
  end
end
