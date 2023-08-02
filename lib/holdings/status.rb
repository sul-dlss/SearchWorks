require 'holdings/status/available'
require 'holdings/status/noncirc'
require 'holdings/status/noncirc_page'
require 'holdings/status/deliver_from_offsite'
require 'holdings/status/unavailable'
require 'holdings/status/in_process'

class Holdings
  class Status
    def initialize(item)
      @item = item
    end

    def availability_class
      case
      when cdl?
        'unavailable cdl'
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

    def cdl?
      @item.home_location == 'CDL'
    end

    def as_json(*)
      { availability_class:, status_text: }
    end
  end
end
