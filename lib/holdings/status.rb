require 'holdings/status/available'
require 'holdings/status/noncirc'
require 'holdings/status/noncirc_page'
require 'holdings/status/deliver_from_offsite'
require 'holdings/status/unavailable'
require 'holdings/status/in_process'

class Holdings
  class Status
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def availability_class
      return folio_availability_class if item.folio_item?

      case
      when in_process?
        'in_process'
      when unavailable?
        'unavailable'
      when noncirc_page?
        'noncirc_page'
      when noncirc?
        'noncirc'
      when deliver_from_offsite?
        'deliver-from-offsite'
      when available?
        'available'
      else
        'unknown'
      end
    end

    def status_text
      I18n.t(availability_class, scope: 'searchworks.availability')
    end

    def folio_availability_class
      case
      when item.folio_status == 'In process', item.folio_status == 'In process (non-requestable)', item.effective_location.details['availabilityClass'] == 'In_process', item.effective_location.details['availabilityClass'] == 'In_process_non_requestable'
        'in_process'
      when item.folio_status == 'On order', item.folio_status == 'Missing', item.folio_status == 'In transit', item.folio_status == 'Paged', item.effective_location.details['availabilityClass'] == 'Unavailable'
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

    # we can probably do something clever w/ method missing here
    def available?
      Holdings::Status::Available.new(@item).available?
    end

    def noncirc?
      Holdings::Status::Noncirc.new(@item).noncirc?
    end

    def noncirc_page?
      Holdings::Status::NoncircPage.new(@item).noncirc_page?
    end

    def deliver_from_offsite?
      Holdings::Status::DeliverFromOffsite.new(@item).deliver_from_offsite?
    end

    def unavailable?
      Holdings::Status::Unavailable.new(@item).unavailable?
    end

    def in_process?
      Holdings::Status::InProcess.new(@item).in_process?
    end

    def as_json(*)
      { availability_class:, status_text: }
    end
  end
end
