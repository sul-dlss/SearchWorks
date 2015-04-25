class Holdings
  class Library
    include AppendMHLD
    attr_reader :code, :items
    attr_accessor :mhld
    def initialize(code, document=nil, items=[])
      @code = code
      @document = document
      @items = items
    end
    def name
      Constants::LIB_TRANSLATIONS[@code]
    end
    def locations
      unless @locations
        @locations = @items.group_by(&:home_location).map do |location_code, items|
          Holdings::Location.new(location_code, items)
        end
        append_mhld(:location, @locations, Holdings::Location)
        @locations.sort_by!(&:sort)
      end
      @locations
    end
    def holding_library?
      !zombie?
    end
    def zombie?
      @code == "ZOMBIE"
    end
    def present?
      @items.any?(&:present?) ||
      (mhld.present? && mhld.any?(&:present?))
    end
    def location_level_request?
      Constants::REQUEST_LIBS.include?(@code) || hopkins_only_and_not_online?
    end
    def library_instructions
      Constants::LIBRARY_INSTRUCTIONS[@code]
    end
    def sort
      if @code == "GREEN"
        '0'
      else
        name || @code
      end
    end

    def as_json(*)
      methods = (public_methods(false) - [:as_json, :items, :locations, :mhld])
      library_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      library_info[:locations] = locations.select(&:present?).map(&:as_json)
      library_info[:mhld] = mhld.select(&:present?).map(&:as_json) if mhld
      library_info
    end

    private

    def hopkins_only_and_not_online?
      hopkins_only? && !document_online?
    end
    def hopkins_only?
      @code == "HOPKINS" &&
      @document.present? &&
      @document.holdings.libraries.present? &&
      @document.holdings.libraries.length == 1
    end
    def hopkins_and_not_online?
      @code == "HOPKINS" && !document_online?
    end
    def document_online?
      @document.present? && @document.access_panels.online?
    end
  end
end
