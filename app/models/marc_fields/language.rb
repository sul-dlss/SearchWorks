# frozen_string_literal: true

##
# A class to merge content from the indexed
# language data and the MARC 546 field
# https://www.loc.gov/marc/bibliographic/bd546.html
class Language < MarcField
  def values
    field_values = super
    return if field_values.blank?

    [[indexed_languages.join(', '), field_values.join(', ')].reject(&:blank?).join('. ')]
  end

  def label
    return I18n.t('searchworks.marc_fields.notation.label') if notation?

    super
  end

  private

  def tags
    %w(546)
  end

  def notation?
    document.document_formats.include?('Music score') && contains_only_subfield_b?
  end

  def contains_only_subfield_b?
    extracted_fields.all? do |_field, subfields|
      subfields.all? do |subfield|
        subfield.code == 'b'
      end
    end
  end

  def indexed_languages
    languages = Array.wrap(document['language'])
    vern_languages = Array.wrap(document['language_vern'])
    [languages, vern_languages].flatten.compact
  end
end
