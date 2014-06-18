class Holdings
  class Callnumber
    def initialize(holding_info)
      @holding_info = holding_info
    end
    def barcode
      item_display[0]
    end
    def library
      item_display[1]
    end
    def home_location
      item_display[2]
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
      item_display[8]
    end
    def full_shelfkey
      item_display[9]
    end
    def course_id
      item_display[10]
    end
    def reserve_desk
      item_display[11]
    end
    def loan_period
      item_display[12]
    end

    def on_reserve?
      reserve_desk.present? && loan_period.present?
    end

    private
    def item_display
      @holding_info.split('-|-').map(&:strip)
    end
  end
end
