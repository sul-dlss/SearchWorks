class Holdings
  class Status
    ##
    # Representing libraries that are in process
    class InProcess
      LIBRARIES = ['HV-ARCHIVE'].freeze

      def initialize(item)
        @item = item
      end

      def in_process?
        library_in_process? && !@item.document&.index_links&.finding_aid.present?
      end

      private

      def library_in_process?
        LIBRARIES.include?(@item.library)
      end
    end
  end
end
