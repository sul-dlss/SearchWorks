# frozen_string_literal: true

module Citeproc
  class Issued
    # Parses a citeproc issued date from MARC 008 field
    # @param [MARC::ControlField] field008
    # @return [Array<Array<Integer>] A list of dates.
    # See https://www.loc.gov/marc/bibliographic/bd008a.html
    # See https://www.oclc.org/bibformats/en/fixedfield/dates.html for how OCLC uses this.
    def self.find(field008)
      type_of_date = field008.value[6]
      date1_raw = field008.value[7..10]
      date1 = date1_raw.to_i
      date2_raw = field008.value[11..14]
      date2 = date2_raw.to_i
      date1_uncertain = date1_raw.ends_with?('u')
      date2_uncertain = date2_raw.ends_with?('u')
      date2_continuing = date2_raw == '9999'

      # Both dates are uncertain
      return if date1_uncertain && (date2_uncertain || date2_continuing)

      case type_of_date
      when 's'
        # s - Single known date/probable date
        [[date1]]
      when 't'
        # t - Publication date and copyright date
        # For some reason we use copyright date.
        [[date2]]
      when 'i', 'c', 'd', 'm'
        # i - Inclusive dates of collection
        # c - Continuing resource currently published
        # d - Continuing resource ceased publication
        # m - Multiple date
        if date1_uncertain
          [[date2]]
        elsif date2_continuing || date2_uncertain
          [[date1]]
        else
          [[date1], [date2]]
        end
      end
    end
  end
end
