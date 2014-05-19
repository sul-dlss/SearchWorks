module LibraryLocations
  def library_locations
    if self.respond_to?(:[])
      @locations ||= LibraryLocations::Processor.new(self)
    end
  end

  private
  class Processor
    def initialize(document)
      @locations = document[:item_display].group_by { |loc| grouped_attributes(loc) }.map { |location| LocationInfo.new(location) } unless document[:item_display].nil?
    end

    def present?
      true ? @locations : false
    end

    def grouped_attributes(loc)
      loc = loc.split('-|-').map { |l| l.strip }
      [loc[1]]
    end

    attr_reader :locations

  end

  class LocationInfo
    def initialize(location)
      @library = location[0][0]
    end

    def is_viewable?
      unless @library == "SUL" || @library == "PHYSICS" || @library == ""
        true
      else
        false
      end
    end

    attr_reader :library
  end

end
