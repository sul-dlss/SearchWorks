# frozen_string_literal: true

##
# A class to parse MARC Series fields that are linked to series searches
# Link text/href is all legal alpha subfields (except $x and $v)
class LinkedSeries < MarcField
  include SeriesLinkable

  def values
    extracted_fields.select { |field, _subfields| series_is_linkable?(field) }.map do |field, subfields|
      subfields.select { |subfield| ('a'..'z').cover?(subfield.code) }.each_with_object({}) do |subfield, hash|
        key = subfield_is_linkable?(field, subfield) ? :link : :extra_text
        hash[key] ||= ''
        hash[key] += "#{subfield.value} "
      end
    end
  end

  def to_partial_path
    'marc_fields/linked_series'
  end

  private

  def subfield_is_linkable?(field, subfield)
    if field.canonical_tag == '490'
      subfield.code == 'a'
    else
      linkable_subfields.include?(subfield.code)
    end
  end

  def linkable_subfields
    ('a'..'z').to_a.reject { |letter| %w(x v).include?(letter) }
  end
end
