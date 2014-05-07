module DatabaseAccessPoint
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_filter)
      before_filter :default_databases_sort, only: :index
    end
    if self.respond_to?(:solr_search_params_logic)
      self.solr_search_params_logic << :database_prefix_search
    end
  end

  protected
  def default_databases_sort
    if page_location.access_point.databases? and params[:sort].blank?
      title_sort = blacklight_config.sort_fields.map do |sort, config|
        sort if config.label == "title"
      end.compact.first
      params[:sort] = title_sort
    end
  end

  def database_prefix_search(solr_params, user_params)
    if page_location.access_point.databases? && user_params[:prefix]
      if user_params[:prefix] == "0-9"
        query = ("0".."9").map do |number|
          "title_sort:#{number}*"
        end.join(" OR ")
      else
        query = "title_sort:#{user_params[:prefix]}*"
      end
      solr_params[:qt] = blacklight_config.lucene_req_handler
      solr_params[:q] = [query, user_params[:q]].compact.join(" AND ")
    end
  end
end