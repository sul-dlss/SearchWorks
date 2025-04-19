# frozen_string_literal: true

# Builds CSL structure from a SolrDocument
# See https://aurimasv.github.io/z2csl/typeMap.xml for the fields
# See https://citeproc-js.readthedocs.io/en/latest/csl-json/markup.html for complex types
class CiteprocItemService
  def self.create(document)
    new(document).item
  end

  def initialize(document)
    @document = document
  end

  attr_reader :document

  delegate :id, to: :document

  def item
    return unless document.respond_to?(:load_marc)

    CiteProc::Item.new(item_attributes)
  end

  AUTHORSHIP_ROLES = %w[author composer].freeze
  private_constant :AUTHORSHIP_ROLES

  private

  def item_attributes
    # TODO: For future optimization: we don't need accessed unless we have a URL. We don't need a URL if we have a DOI.
    { id:, author:, issued:, title:, type:, publisher:, 'DOI' => doi, 'URL' => url,
      accessed: [Time.zone.now.to_a[3..5].reverse], edition:, translator:, editor: }.compact_blank
  end

  def marc
    @marc ||= document.load_marc
  end

  def author
    (person_author + corporate_author).uniq
  end

  def author_filter
    @author_filter ||= lambda { |field|
      relators = field.subfields.select { it.code == 'e' }
      relators.empty? || relators.map { strip_trailing_punct(it.value) }.intersect?(AUTHORSHIP_ROLES)
    }
  end

  def person_author
    # https://loc.gov/marc/bibliographic/bd700.html

    extract_personal_names('100', author_filter) + extract_personal_names('700', author_filter)
  end

  # Second argument is a filter on the field
  def extract_personal_names(tag, filter)
    filter_tag(tag).flat_map do |field|
      field.filter_map { |subfield| extract_personal_name(field.indicator1, strip_trailing_punct(subfield.value)) if subfield.code == 'a' } if filter.call(field)
    end
  end

  def extract_personal_name(indicator1, val)
    # See https://www.loc.gov/marc/bibliographic/bdx00.html
    if indicator1 == '1'
      # Split into family/given
      (family, given) = val.split(', ')
      { family:, given: }
    else
      { literal: val }
    end
  end

  def filter_tag(tag)
    marc.fields.select { |field| field.tag == tag }
  end

  def strip_trailing_punct(val)
    val.gsub(/[.,]\z/, '')
  end

  def subfield_values(field, codes)
    field.subfields.filter_map { |subfield| strip_trailing_punct(subfield.value) if codes.include?(subfield.code) }.join(" ")
  end

  # 110a + 710 a & b
  def corporate_author
    (filter_tag('110') + filter_tag('710')).filter_map { |field| { literal: subfield_values(field, %w[a b]) } if author_filter.call(field) }
  end

  def edition
    field = marc['250']
    return unless field

    field.select { |subfield| subfield.code == 'a' }.map(&:value).join(' ')
  end

  def translator
    role('translator')
  end

  def editor
    role('editor')
  end

  def role(role_name)
    filter = lambda { |field|
      field.subfields.find { it.code == 'e' && strip_trailing_punct(it.value) == role_name }
    }
    filter_tag('710').filter_map { |field| { literal: subfield_values(field, %w[a b]) } if filter.call(field) } +
      extract_personal_names('700', filter)
  end

  def issued
    date = Citeproc::Issued.find(marc['008'])
    { 'date-parts': [[date]] } if date
  end

  def title
    marc['245'].select { |subfield| %w[a b].include?(subfield.code) }.map { strip_trailing_punct(it.value) }.join(' ').delete_suffix(' /')
  end

  # Type is important because the CSL may
  def type
    # https://www.loc.gov/marc/bibliographic/bdleader.html
    case marc.leader[6]
    when 'a'
      'book'
    when 'c' # music
      'song'
    when 'e'
      'map'
    else
      'document'
    end
  end

  def publisher
    field260 = Array(marc['260']).filter_map { |subfield| subfield.value.delete_suffix(',') if subfield.code == 'b' }.join(' ')
    return field260 if field260.present?

    Array(marc['264']).filter_map { |subfield| subfield.value.delete_suffix(',') if subfield.code == 'b' }.join(' ')
  end

  def doi
    # See https://www.loc.gov/marc/authority/ad024.html
    field024 = marc.fields.find { |field| field.tag == '024' && field.indicator1 == '7' }
    return unless field024

    identifier_type = field024.subfields.find { |subfield| subfield.code == '2' }&.value
    field024.subfields.find { |subfield| subfield.code == 'a' }&.value if identifier_type == 'doi'
  end

  def url
    # https://www.loc.gov/marc/bibliographic/bd856.html
    field_856_for_resource = marc.fields.find { |field| field.tag == '856' && field.indicator2 == '0' }
    return unless field_856_for_resource

    field_856_for_resource.subfields.find { |subfield| subfield.code == 'u' }&.value
  end
end
