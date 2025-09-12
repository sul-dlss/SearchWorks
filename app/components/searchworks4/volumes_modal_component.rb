# frozen_string_literal: true

module Searchworks4
  class VolumesModalComponent < ViewComponent::Base
    def initialize(call_number:, response:)
      super()
      @call_number = call_number
      @response = response
    end

    def results
      @response.dig(:response, :docs)
    end

    def call_number_display(solr_doc)
      call_number = ''
      if solr_doc.key?('lc_assigned_callnum_ssim')
        call_number = solr_doc['lc_assigned_callnum_ssim'].join(', ')
      elsif solr_doc.key?('item_display_struct')
        call_number = solr_doc['item_display_struct'][0]['callnumber']
      else
        call_number = ''
      end
      call_number
    end
  end
end