class Holdings
  class Status
    class Noncirc
      NONCIRC_TYPES = %w(ARCHIVE EXPEDITION INDEX LIBUSEONLY MFICHE MFILM NH-INHOUSE NH-MAP NONCIRC REF VAULT).freeze

      def initialize(item)
        @item = item
      end

      def noncirc?
        return @noncirc unless @noncirc.nil?

        @noncirc = location_is_noncirc? || type_is_noncirc?
      end

      private

      def location_is_noncirc?
        case @item.library
        when 'BUSINESS'
          Constants::NONCIRC_LOCS.push("NEWS-STKS", "MICROFILM").include?(@item.home_location)
        else
          Constants::NONCIRC_LOCS.include?(@item.home_location)
        end
      end

      def type_is_noncirc?
        case @item.library
        when 'ARS'
          @item.type != "STKS" || NONCIRC_TYPES.include?(@item.type)
        else
          NONCIRC_TYPES.include?(@item.type)
        end
      end
    end
  end
end
