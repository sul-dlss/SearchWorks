class Holdings
  class Location
    attr_reader :code, :items, :mhld

    # @params [String] code the location code (e.g. 'GRE-STACKS')
    # @params [Array<Holdings::Item>] items ([]) a list of items at this location.
    # @params [Array<Holdings::MHLD>] mhld ([]) a list of mhlds at this location.
    def initialize(code, items = [], mhld = [])
      @code = code
      @items = items.sort_by(&:full_shelfkey)
      @mhld = mhld
    end

    def name
      return if @code.blank?

      Folio::Locations.label(code: @code)
    end

    def stackmapable?
      stackmap_api_url.present?
    end

    def stackmap_api_url
      details['stackmapBaseUrl']
    end

    def details
      Folio::Locations.details(code: @code) || {}
    end

    def bound_with?
      items.any?(&:bound_with?)
    end

    # Intentionally left blank
    def location_link; end

    def present?
      any_items? || any_mhlds? || bound_with?
    end

    def present_on_index?
      any_items? || any_index_mhlds? || @code == 'SEE-OTHER'
    end

    def sort
      name || @code
    end

    # This prevents logging too much data when there is an error.
    def inspect
      "<##{this.class.class_name} @code=#{@code}>"
    end

    private

    def any_items?
      items.reject(&:suppressed?).any?
    end

    def any_mhlds?
      mhld.any?(&:present?)
    end

    def any_index_mhlds?
      mhld.any? do |mhld_item|
        mhld_item.latest_received.present? ||
          mhld_item.public_note.present?
      end
    end
  end
end
