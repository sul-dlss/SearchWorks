class Holdings
  class Status
    class Noncirc
      NONCIRC_TYPES = %w(ARCHIVE EXPEDITION INDEX LIBUSEONLY MFICHE MFILM NH-INHOUSE NH-MAP NONCIRC REF VAULT).freeze

      def initialize(callnumber)
        @callnumber = callnumber
      end

      def noncirc?
        return @noncirc unless @noncirc.nil?

        @noncirc = location_is_noncirc? || type_is_noncirc?
      end

      private

      def location_is_noncirc?
        case @callnumber.library
        when 'BUSINESS'
          Constants::NONCIRC_LOCS.concat(["NEWS-STKS", "MICROFILM"]).include?(@callnumber.home_location)
        else
          Constants::NONCIRC_LOCS.include?(@callnumber.home_location)
        end
      end

      def type_is_noncirc?
        case @callnumber.library
        when 'ARS'
          @callnumber.type != "STKS" || NONCIRC_TYPES.include?(@callnumber.type)
        else
          NONCIRC_TYPES.include?(@callnumber.type)
        end
      end
    end
  end
end
