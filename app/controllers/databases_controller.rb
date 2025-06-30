# frozen_string_literal: true

class DatabasesController < ApplicationController
  layout 'searchworks4'

  def self.local_prefixes
    super + ['catalog']
  end

  include Blacklight::Catalog
  include EmailValidation
  include CatalogEmailSending

  copy_blacklight_config_from(CatalogController)

  configure_blacklight do |config|
    config.facet_fields.clear
    config.search_fields.clear
    config.add_search_field('search')
    config.view.delete(:gallery)

    config.default_solr_params[:fq] = ['format_main_ssim:Database']
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
end
