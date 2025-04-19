# frozen_string_literal: true

module Citeproc
  class Issued
    # Parses a citeproc issued date from MARC 008 field
    # @param [MARC::ControlField] field008
    # See https://www.loc.gov/marc/bibliographic/bd008a.html
    # See https://www.oclc.org/bibformats/en/fixedfield/dates.html for how OCLC uses this.
    def self.find(field008)
      type_of_date = field008.value[6]
      date1 = field008.value[7..10].to_i
      date2 = field008.value[11..14].to_i

      # Both dates are uncertain
      return if field008.value[7..10].ends_with?('u') && field008.value[11..14].ends_with?('u')

      case type_of_date
      when 's'
        # s - Single known date/probable date
        date1
      when 't'
        # t - Publication date and copyright date
        # For some reason we use copyright date.
        date2
      when 'i', 'd', 'm'
        # i - Inclusive dates of collection
        # d - Continuing resource ceased publication
        # m - Multiple date
        date2 = date1 if date2 == 9999 # Multipart item for which the publication date is ongoing.
        date2 = date1 if field008.value[11..14].ends_with?('uu') # Ending date is unknown
        date2
      end
    end
  end
end
