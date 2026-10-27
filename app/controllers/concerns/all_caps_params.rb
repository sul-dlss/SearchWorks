# frozen_string_literal: true

module AllCapsParams
  extend ActiveSupport::Concern

  included do
    before_action :downcase_all_caps_params, only: :index if respond_to?(:before_action)
  end

  private

  def downcase_all_caps_params
    downcase_all_caps_param params, :q

    params[:clause]&.each_value do |clause_hash|
      downcase_all_caps_param clause_hash, :query
    end
  end

  def downcase_all_caps_param(hash, key)
    return if hash[key].blank?

    query = hash[key]

    return unless query.upcase == query

    hash[key] = query.downcase
  end
end
