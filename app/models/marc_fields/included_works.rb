# frozen_string_literal: true

##
# A class to handle MARC 7xx field logic for included works
class IncludedWorks < MarcField
  def to_partial_path
    'marc_fields/included_works'
  end

  private

  def display_value(_field, relevant_subfields)
    before_text = []
    link_text = []
    href_text = []

    before_t, *after_t = relevant_subfields.slice_before { |subfield| subfield.code == 't' }.to_a
    within_t, *extra_fields = after_t.flatten.slice_after { |subfield| subfield.value =~ /[\.|;]\s*$/ }.to_a

    # With values until we get to subfield t
    text_only_subfields = ["e", "j", "4"]
    before_t.each do |subfield|
      if subfield.code == "i"
        before_text << subfield.value.gsub(/\s*\(.+\)\s*/, '')
      else
        href_text << subfield.value unless text_only_subfields.include?(subfield.code)
        link_text << subfield.value
      end
    end

    # with values between the subfield t and some punctuation
    text_only_subfields = ["e", "i", "j", "4"]
    within_t.each do |subfield|
      href_text << subfield.value unless text_only_subfields.include?(subfield.code)
      link_text << subfield.value
    end

    {
      query_text: href_text.join(' ').presence,
      link_text: link_text.join(' ').presence,
      before_text: before_text.join(' ').presence,
      after_text: extra_fields.flatten.map(&:value).join(' ').presence
    }
  end

  def extracted_fields
    super.select do |(field, _subfields)|
      field['t'].present? && field.indicator2 == '2'
    end
  end

  def tags
    %w[700 710 711 720]
  end
end
