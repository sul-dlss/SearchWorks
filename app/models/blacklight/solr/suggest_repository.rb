# frozen_string_literal: true

module Blacklight::Solr
  class SuggestRepository < Blacklight::Solr::Repository
    # @param [Hash] request_params
    # @return {suggester_name: [suggest response]}
    def suggestions(request_params)
      request_params['suggest.dictionary'] = suggester_names
      request_params['suggest.build'] = true
      # We may not need this but just in case
      request_params['suggest.q'] = request_params[:q]
      suggest_results = connection.send_and_receive(suggest_handler_path, params: request_params) 
      results = {}
      suggester_names.each do |suggester_name|
        results[suggester_name] = (suggest_results.dig(suggest_handler_path, suggester_name, request_params[:q], 'suggestions') || []).uniq 
      end
      results
    end

    def suggester_names
      ['mySuggester', 'mySuggesterPrefix', 'defaultAnalyzing', 'defaultBlended']
    end
  end
end