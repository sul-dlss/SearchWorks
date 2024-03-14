# frozen_string_literal: true

class SearchQueryModifier
  def initialize(search_state)
    @search_state = search_state
    @params = @search_state.params
    @config = @search_state.blacklight_config
  end

  def params_without_fielded_search_and_filters
    @params.merge(search_field: nil, f: nil, range: nil).except(:controller, :action)
  end

  def params_without_fielded_search
    @params.merge(search_field: nil).except(:controller, :action)
  end

  def fielded_search?
    @params[:q].present? &&
    @params[:search_field].present? &&
    @params[:search_field] != @config.default_search_field.field
  end

  def params_without_filters
    @params.merge(f: nil, range: nil).except(:controller, :action)
  end

  def has_filters?
    @params[:f].present? || @params[:range].present?
  end

  def has_query?
    @params[:q].present?
  end
end
