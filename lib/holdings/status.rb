class Holdings
  class Status
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def availability_class
      case
      when item.folio_status == 'In process', item.folio_status == 'In process (non-requestable)', item.availability_class == 'In_process', item.availability_class == 'In_process_non_requestable'
        'in_process'
      when item.folio_status == 'On order', item.folio_status == 'Missing', item.folio_status == 'In transit', item.folio_status == 'Paged', item.availability_class == 'Unavailable'
        'unavailable'
      when item.availability_class == 'Offsite' && !item.circulates?
        'noncirc_page'
      when item.availability_class == 'Offsite'
        'deliver-from-offsite'
      when !item.circulates?
        'noncirc'
      when item.availability_class == 'Available'
        'available'
      else
        'unknown'
      end
    end

    def status_text
      I18n.t(availability_class, scope: 'searchworks.availability')
    end

    def as_json(*)
      { availability_class:, status_text: }
    end
  end
end
