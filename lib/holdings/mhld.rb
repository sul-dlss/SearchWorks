class Holdings
  class MHLD
    def initialize(mhld_display)
      @mhld_display = mhld_display.split('-|-').map(&:strip)
    end

    def library
      @mhld_display[0]
    end

    def location
      @mhld_display[1]
    end

    def public_note
      sanitize_mhld_data @mhld_display[2]
    end

    def library_has
      sanitize_mhld_data @mhld_display[3]
    end

    def latest_received
      sanitize_mhld_data @mhld_display[4]
    end

    private

    def sanitize_mhld_data(data)
      data.gsub("),","), ").gsub("-","-<wbr/>")
    end
  end
end
