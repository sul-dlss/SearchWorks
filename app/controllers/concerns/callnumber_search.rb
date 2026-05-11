# frozen_string_literal: true

module CallnumberSearch
  extend ActiveSupport::Concern

  included do
    if self.respond_to?(:before_action)
      prepend_before_action :quote_and_downcase_callnumber_search, only: :index
    end
  end

  private

  def quote_and_downcase_callnumber_search
    if params[:search_field] == 'call_number' && params[:q]
      params[:q] = params[:q].downcase
      params[:q] = "\"#{params[:q]}\"" unless params[:q].include?('"')
    end
  end
end
