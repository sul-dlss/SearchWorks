# frozen_string_literal: true

##
# Mixin to be used when parsing MARC series fields
# MARC series fields are 440, 490, 800, 810, 811, and 830
# A series field is linkable as long as there are not multiple $a.
# A 490 is only linkable if the first indicator is 0
module SeriesLinkable
  def values
    extracted_fields.map do |_field, subfields|
      subfields.select { |subfield| ('a'..'z').cover?(subfield.code) }.map(&:value).join(subfield_delimiter)
    end
  end

  private

  def series_is_linkable?(field)
    !many_subfield_a?(field) && field_490_has_first_indicator_0?(field)
  end

  def many_subfield_a?(field)
    field.subfields.many? { |subfield| subfield.code == 'a' }
  end

  def field_490_has_first_indicator_0?(field)
    return true unless field.canonical_tag == '490'

    field.indicator1 == '0'
  end

  def tags
    %w(440 490 800 810 811 830)
  end
end
