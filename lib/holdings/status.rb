require 'holdings/available'
require 'holdings/noncirc'
require 'holdings/noncirc_page'
require 'holdings/pageable'
require 'holdings/unavailable'
require 'holdings/unknown'

class Holdings
  class Status
    def initialize(callnumber)
      @callnumber = callnumber
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
      when pageable?
        'page'
      when available?
        'available'
      when unknown?
        'unknown'
      else
        'unknown'
      end
    end

    def status_text
      Constants::TRANSLATE_STATUS[availability_class]
    end

    # we can probably do something clever w/ method missing here
    def available?
      Holdings::Status::Available.new(@callnumber).available?
    end

    def noncirc?
      Holdings::Status::Noncirc.new(@callnumber).noncirc?
    end

    def noncirc_page?
      Holdings::Status::NoncircPage.new(@callnumber).noncirc_page?
    end

    def pageable?
      Holdings::Status::Pageable.new(@callnumber).pageable?
    end

    def unavailable?
      Holdings::Status::Unavailable.new(@callnumber).unavailable?
    end

    def unknown?
      Holdings::Status::Unknown.new(@callnumber).unknown?
    end

    def in_process?
      Holdings::Status::InProcess.new(@callnumber).in_process?
    end

    def cdl?
      @callnumber.home_location == 'CDL'
    end

    def as_json(*)
      { availability_class: availability_class, status_text: status_text }
    end
  end
end
