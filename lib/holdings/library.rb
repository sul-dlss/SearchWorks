class Holdings
  class Library
    include AppendMHLD
    attr_reader :code, :items
    attr_accessor :mhld

    def initialize(code, document = nil, items = [])
      @code = code
      @document = document
      @items = items
    end

    def name
      Constants::LIB_TRANSLATIONS[@code]
    end

    def locations
      unless @locations
        @locations = @items.group_by do |item|
          Constants::LOCS[item.home_location] || item.home_location
        end.map do |_, items|
          Holdings::Location.new(items.first.home_location, items, @document)
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
      @code == 'ZOMBIE'
    end

    def hoover_archive?
      @code == 'HV-ARCHIVE'
    end

    def present?
      @items.any?(&:present?) ||
        (mhld.present? && mhld.any?(&:present?)) ||
        locations.any?(&:bound_with?)
    end

    def library_instructions
      Constants::LIBRARY_INSTRUCTIONS[@code]
    end

    def sort
      if @code == 'GREEN'
        '0'
      else
        name || @code
      end
    end

    def as_json(live_data = [])
      methods = (public_methods(false) - [:as_json, :items, :locations, :mhld])
      library_info = methods.each_with_object({}) do |meth, obj|
        obj[meth.to_sym] = send(meth) if method(meth).arity == 0
      end
      library_info[:locations] = locations.select(&:present?).map do |location|
        location.as_json(live_data)
      end
      library_info[:mhld] = mhld.select(&:present?).map(&:as_json) if mhld
      library_info
    end
  end
end
