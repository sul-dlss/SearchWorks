# frozen_string_literal: true

module Blacklight::Solr
  class SuggestRepository < Blacklight::Solr::Repository
    # @param [Hash] request_params
    # @return {suggester_name: [suggest response]}
    def suggestions(request_params)
      # Suggester name returns the suggester name configured in catalog controller
      # Adding this parameter explicitly requests that dictionary which may not be configured to return by default
      request_params['suggest.dictionary'] = suggester_name
      results = connection.send_and_receive(suggest_handler_path, params: request_params) 
      (results.dig(suggest_handler_path, suggester_name, request_params[:q], 'suggestions') || []).uniq 
    end
  end
end