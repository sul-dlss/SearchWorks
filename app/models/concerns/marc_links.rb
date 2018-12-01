module MarcLinks
  def marc_links
    @marc_links ||= LinksWrapper.new(fetch(:marc_links_struct, []).map do |data|
      SearchWorks::Links::Link.new(data)
    end)
  end

  class LinksWrapper < SearchWorks::Links
    def initialize(data)
      @data = data
    end

    def all
      @data
    end
  end
end
