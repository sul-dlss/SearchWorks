# frozen_string_literal: true

class Holdings
  class Status
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def availability_class
      if item.folio_item?
        folio_availability_class
      elsif item.on_order?
        'unavailable'
      else
        'unknown'
      end
    end

    def status_text
      I18n.t(availability_class, scope: 'searchworks.availability')
    end

    def folio_availability_class
      if ['In process', 'In process (non-requestable)'].include?(item.folio_status) || %w[In_process In_process_non_requestable].include?(item.location_provided_availability)
        'in_process'
      elsif ['On order', 'Missing', 'In transit', 'Paged'].include?(item.folio_status) || item.location_provided_availability == 'Unavailable'
        'unavailable'
      elsif item.location_provided_availability == 'Offsite' && !item.circulates?
        'noncirc_page'
      elsif item.location_provided_availability == 'Offsite'
        'deliver-from-offsite'
      elsif !item.circulates?
        'noncirc'
      elsif item.location_provided_availability == 'Available'
        'available'
      else
        'unknown'
      end
    end
  end
end
