module AdvancedSearchParamsMapping
  extend ActiveSupport::Concern
  included do
    if self.respond_to?(:before_action)
      before_action :map_advanced_search_params, only: :index
    end
  end

  private

  def map_advanced_search_params
    if params[:search_field] == blacklight_config.advanced_search[:url_key]
      if params[:author]
        params[:search_author] = params[:author]
        params.delete(:author)
      end
      if params[:title]
        params[:search_title] = params[:title]
        params.delete(:title)
      end
      if params[:subject]
        params[:subject_terms] = params[:subject]
        params.delete(:subject)
      end
      if params[:description]
        params[:search] = params[:description]
        params.delete(:description)
      end
      if params[:pub_info]
        params[:pub_search] = params[:pub_info]
        params.delete(:pub_info)
      end
      if params[:number]
        params[:isbn_search] = params[:number]
        params.delete(:number)
      end
    end
  end
end
