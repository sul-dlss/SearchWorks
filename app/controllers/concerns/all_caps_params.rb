module AllCapsParams
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_filter)
      before_filter :downcase_all_caps_params, only: :index
    end
  end

  private

  def modifiable_params_keys
    %w[q search search_author search_title subject_terms series_search pub_search isbn_search]
  end

  def downcase_all_caps_params
    modifiable_params_keys.each do |param|
      if params.has_key?(param)
        downcase_all_caps_param param, params[param]
      end
    end
  end

  def downcase_all_caps_param param, query
    if query.upcase == query
      params[param] = query.downcase
    end
  end
end
