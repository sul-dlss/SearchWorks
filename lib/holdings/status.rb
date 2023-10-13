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
      case
      when ['In process', 'In process (non-requestable)'].include?(item.folio_status), item.effective_location.details['availabilityClass'] == 'In_process', item.effective_location.details['availabilityClass'] == 'In_process_non_requestable'
        'in_process'
      when ['On order', 'Missing', 'In transit', 'Paged'].include?(item.folio_status), item.effective_location.details['availabilityClass'] == 'Unavailable'
        'unavailable'
      when item.effective_location.details['availabilityClass'] == 'Offsite' && !item.circulates?
        'noncirc_page'
      when item.effective_location.details['availabilityClass'] == 'Offsite'
        'deliver-from-offsite'
      when !item.circulates?
        'noncirc'
      when item.effective_location.details['availabilityClass'] == 'Available'
        'available'
      else
        'unknown'
      end
    end

    def as_json(*)
      { availability_class:, status_text: }
    end
  end
end
