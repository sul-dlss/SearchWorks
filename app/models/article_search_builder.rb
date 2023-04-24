# Keep distinct from catalog's SearchBuilder
class ArticleSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  self.default_processor_chain = %i[add_eds_params strip_nil_f]

  private

  # See EBSCO::EDS::RetrievalCriteria
  def add_eds_params(eds_params)
    # avoid the Solr-like EDS API parameters
    eds_params.merge!(blacklight_params.to_hash.except('start', 'rows', 'page', 'per_page'))

    # Blacklight (now) uses arrays for the ranges
    eds_params[:range]&.each do |key, field|
      filter = search_state.filter(key)

      filter.each_value do |value|
        eds_params[:range][key] = { begin: value.first.to_s, end: value.last.to_s }
      end
    end

    eds_params[:page_number] = page
    eds_params[:results_per_page] = rows
    eds_params[:view] = 'detailed'
    eds_params[:highlight] = 'y' # TODO: must be true in order to workaround EDS bug with missing research starter abstracts. See https://github.com/ebsco/edsapi-ruby/issues/55
  end

  # The EDS gem doesn't handle the nil f and throws a generic error
  def strip_nil_f(solr_params)
    solr_params.delete('f') unless solr_params['f']
  end
end
