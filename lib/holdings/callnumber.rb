class Holdings
  class Callnumber
    attr_writer :current_location, :status
    attr_accessor :due_date
    def initialize(holding_info)
      @holding_info = holding_info
    end

    def present?
      @holding_info.present? &&
        !(item_display[1] == 'SUL' && item_display[2] == 'INTERNET')
    end

    def browsable?
      shelfkey.present? &&
        reverse_shelfkey.present? &&
        item_display[8].present? &&
        Constants::BROWSABLE_CALLNUMBERS.include?(callnumber_type)
    end

    def on_order?
      barcode.blank? &&
        home_location == 'ON-ORDER' &&
        current_location.code == 'ON-ORDER'
    end

    def barcode
      item_display[0]
    end

    def library
      if current_location_is_reserve_desk?
        Constants::RESERVE_DESKS[current_location.code]
      else
        standard_or_zombie_library
      end
    end

    def home_location
      if treat_current_location_as_home_location?
        reserve_desk_or_current_location
      else
        item_display[2]
      end
    end

    def current_location
      Holdings::Location.new(item_display[3])
    end

    def type
      item_display[4]
    end

    def truncated_callnumber
      item_display[5]
    end

    def shelfkey
      item_display[6]
    end

    def reverse_shelfkey
      item_display[7]
    end

    def callnumber
      if item_display[8].present?
        item_display[8]
      else
        '(no call number)'
      end
    end

    def full_shelfkey
      item_display[9]
    end

    def public_note
      item_display[10].gsub('.PUBLIC.', '').strip if item_display[10]
    end

    def callnumber_type
      item_display[11]
    end

    def course_id
      item_display[12]
    end

    def reserve_desk
      item_display[13]
    end

    def loan_period
      item_display[14]
    end

    def status
      @status ||= Holdings::Status.new(self)
    end

    def on_reserve?
      reserve_desk.present? && loan_period.present?
    end

    def treat_current_location_as_home_location?
      Constants::CURRENT_HOME_LOCS.include?(current_location.code)
    end

    delegate :requestable?, to: :request_status

    delegate :must_request?, to: :request_status

    def has_stackmap?
      library == 'GREEN' && home_location !~ /GREEN-RESV|GRE-LOAN|SL3-LOAN|SLN-LOAN/i
    end

    def live_status?
      library != 'LANE-MED'
    end

    def as_json(*)
      methods = (public_methods(false) - [:as_json, :status, :current_location])
      callnumber_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      callnumber_info[:current_location] = current_location.as_json
      callnumber_info[:status] = status.as_json
      callnumber_info
    end

    private

    def standard_or_zombie_library
      if item_display[1].blank? || %w(SUL PHYSICS).include?(item_display[1])
        'ZOMBIE'
      else
        item_display[1]
      end
    end

    def reserve_desk_or_current_location
      if current_location_is_reserve_desk?
        reserve_desk_home_location
      else
        current_location.code
      end
    end

    def reserve_desk_home_location
      if current_location.code == 'E-RESV'
        'SW-E-RESERVE-DESK'
      else
        'SW-RESERVE-DESK'
      end
    end

    def current_location_is_reserve_desk?
      Constants::RESERVE_DESKS.keys.include?(current_location.code)
    end

    def request_status
      @request_status ||= Holdings::Requestable.new(self)
    end

    def item_display
      @item_display ||= @holding_info.split('-|-').map(&:strip)
    end
  end
end
