class SearchQueryModifier
  def initialize(search_state)
    @search_state = search_state
    @params = @search_state.params
    @config = @search_state.blacklight_config
  end

  def present?
    has_filters_and_query? || fielded_search? || query_has_stopwords?
  end

  def params_without_stopwords
    @params.merge(q: query_without_stopwords)
  end

  def query_has_stopwords?
    has_query? && @params[:q].split.any? do |word|
      SearchQueryModifier.stopwords.include?(word.downcase)
    end
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

  def selected_filter_labels
    if has_filters?
      @config.facet_fields.values.map do |facet|
        "#{facet.label} > #{@params[:f][facet.field].join(', ')}" if @params[:f].present? && @params[:f][facet.field].present?
      end.compact.join('+ ')
    end
  end

  def has_filters?
    @params[:f].present? || @params[:range].present?
  end

  def has_query?
    @params[:q].present?
  end

  def self.stopwords
    %w{and of the}
  end

  private

  def has_filters_and_query?
    has_filters? && has_query?
  end

  def query_without_stopwords
    if has_query?
      @params[:q].split.reject do |word|
        SearchQueryModifier.stopwords.include?(word.downcase)
      end.join(' ')
    end
  end
end
