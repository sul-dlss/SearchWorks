class Holdings
  class Status
    class Pageable
      def initialize(item)
        @item = item
      end

      def pageable?
        return folio_pageable? if Settings.features.folio

        pageable_home_location? || pageable_library?
      end

      private

      delegate :folio_pageable?, to: :@item

      def pageable_library?
        ["SAL3", "SAL-NEWARK"].include?(@item.library)
      end

      def pageable_home_location?
        @item.home_location.try(:end_with?, '-30') ||
        Constants::PAGE_LOCS.include?(@item.home_location)
      end
    end
  end
end
