##
# A class to merge content from the indexed
# language data and the MARC 546 field
# https://www.loc.gov/marc/bibliographic/bd546.html
class Language < MarcField
  def values
    [[indexed_languages.join(', '), super.join(', ')].reject(&:blank?).join('. ')]
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
    document_formats.include?('Music score') && contains_only_subfield_b?
  end

  def contains_only_subfield_b?
    relevant_fields.all? do |field|
      field.subfields.all? do |subfield|
        subfield.code == 'b'
      end
    end
  end

  def indexed_languages
    languages = Array.wrap(document['language'])
    vern_languages = Array.wrap(document['language_vern'])
    [languages, vern_languages].flatten.compact
  end

  def document_formats
    document[document.format_key] || []
  end
end
