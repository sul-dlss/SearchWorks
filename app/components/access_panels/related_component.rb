module AccessPanels
  class RelatedComponent < AccessPanels::Base
    def oclc
      document[:oclc]
    end
  end
end
