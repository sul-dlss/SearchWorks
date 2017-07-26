# Keep distinct from catalog's SearchBuilder
class ArticleSearchBuilder < Blacklight::SearchBuilder
  include Blacklight::Solr::SearchBuilderBehavior
  self.default_processor_chain = %i[add_eds_params]

  private

  # See EBSCO::EDS::RetrievalCriteria
  def add_eds_params(eds_params)
    eds_params.merge!(blacklight_params.to_hash)
    eds_params.except!('start', 'rows', 'page', 'per_page') # avoid the Solr-like EDS API parameters
    eds_params[:page_number] = page
    eds_params[:results_per_page] = rows
    eds_params[:highlight] = 'y' # TODO: must be true in order to workaround EDS bug with missing research starter abstracts. See https://github.com/ebsco/edsapi-ruby/issues/55
    eds_params['search_field'] = 'descriptor' if eds_params['search_field'] == 'subject'
  end
end
