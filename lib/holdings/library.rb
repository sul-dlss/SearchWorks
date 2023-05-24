class Holdings
  class Library
    attr_reader :code, :items, :mhld

    def initialize(code, items = [], mhld = [])
      @code = code
      @items = items
      @mhld = mhld
    end

    def name
      config = Settings.libraries[@code]
      return config.name if config

      Honeybadger.notify("No library config", context: { code: @code })
      nil
    end

    def locations
      unless @locations
        @locations = @items.group_by do |item|
          Constants::LOCS[item.home_location] || item.home_location
        end.map do |_, items|
          mhlds = mhld.select { |x| x.location == items.first.home_location }
          Holdings::Location.new(items.first.home_location, items, mhlds)
        end

        @locations += mhld.reject { |x| @locations.map(&:code).include? x.location }.group_by(&:location).map do |code, mhlds|
          Holdings::Location.new(code, [], mhlds)
        end

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

    def as_json
      {
        code:,
        locations: locations.select(&:present?).map(&:as_json),
        mhld: mhld.select(&:present?).map(&:as_json),
        name:,
        library_instructions:
      }
    end
  end
end
