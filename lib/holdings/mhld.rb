class Holdings
  class MHLD
    def initialize(mhld_display)
      @mhld_display = mhld_display.split('-|-').map(&:strip)
    end

    def library
      standard_or_zombie_library
    end

    def location
      @mhld_display[1].presence # cast empty string to nil
    end

    def present?
      public_note.present? ||
        library_has.present? ||
        latest_received.present?
    end

    def public_note
      sanitize_mhld_data(@mhld_display[2])
    end

    def library_has
      sanitize_mhld_data(@mhld_display[3])
    end

    def latest_received
      sanitize_mhld_data(@mhld_display[4])
    end

    private

    def standard_or_zombie_library
      if @mhld_display[0].blank? || %w(SUL PHYSICS).include?(@mhld_display[0])
        'ZOMBIE'
      else
        @mhld_display[0]
      end
    end

    def sanitize_mhld_data(data)
      return if data.blank?

      CGI.escape_html(data.gsub(/;\s?/, '; ').gsub('),', '), ').gsub(/,\s?/, ', ')).gsub('-', '-<wbr/>').html_safe
    end
  end
end
