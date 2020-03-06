module AllCapsParams
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_action)
      before_action :downcase_all_caps_params, only: :index
    end
  end

  private

  def downcase_all_caps_params
    modifiable_params_keys.each do |param|
      if params[param]
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
