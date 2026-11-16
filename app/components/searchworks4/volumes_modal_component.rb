# frozen_string_literal: true

module Searchworks4
  class VolumesModalComponent < ViewComponent::Base
    def initialize(call_number:, response:, title:)
      super()
      @call_number = call_number
      @response = response
      @title = title
    end

    def results
      @response.dig(:response, :docs)
    end

    def call_number_display(solr_doc)
      if solr_doc.key?('lc_assigned_callnum_ssim')
        solr_doc['lc_assigned_callnum_ssim'].join(', ')
      elsif solr_doc.key?('item_display_struct')
        solr_doc['item_display_struct'][0]['callnumber']
      else
        ''
      end
    end

    def show_search?
      results.length > 4
    end
  end
end
