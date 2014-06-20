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
      when noncirc_page?
        'noncirc_page'
      when noncirc?
        'noncirc'
      when pageable?
        'page'
      when available?
        'available'
      when unavailable?
        'unavailable'
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

  end
end
