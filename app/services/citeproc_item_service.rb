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
    CiteProc::Item.new(item_attributes)
  end

  private

  def item_attributes
    { id:, author:, issued:, title:, type:, publisher:, 'URL' => url }.compact_blank
  end

  def marc
    @marc ||= document.load_marc
  end

  def author
    person_author + corporate_author
  end

  def person_author
    # https://loc.gov/marc/bibliographic/bd700.html
    Array(marc['100']&.select { |subfield| subfield.code == 'a' }&.map(&:value)&.map do |val|
      { literal: val.gsub(/[.,]\z/, '') }
    end) +
      marc.fields.select { it.tag == '700' }.map do |field|
        { literal: field.subfields.select { |subfield| subfield.code == 'a' }&.map(&:value)&.join(' ') }
      end
  end

  def corporate_author
    Array(marc['110']&.select { |subfield| subfield.code == 'a' }&.map(&:value)&.map do |val|
      { literal: val.delete_suffix('.') }
    end) +
      marc.fields.select { |field| field.tag == '710' }.map do |field|
        { literal: field.subfields.map { |subfield| subfield.value.delete_suffix('.') }.join(" ") }
      end
  end

  def issued
    # https://www.loc.gov/marc/bibliographic/bd008a.html
    debugger
    return if marc['008'].value[6] == 'd'

    { 'date-parts': [[marc['008'].value[7..10]]] }
  end

  def title
    marc['245'].select { |subfield| %w[a b].include?(subfield.code) }.map { it.value.gsub(/[.,]\z/, '') }.join(' ').delete_suffix(' /')
  end

  def type
    field_245h = marc['245'].find { |subfield| subfield.code == 'h' }
    return 'document' unless field_245h

    field_245h.value.gsub(/[\[\].]/, '')
  end

  def publisher
    field260 = Array(marc['260']).filter_map { |subfield| subfield.value.delete_suffix(',') if subfield.code == 'b' }.join(' ')
    return field260 if field260.present?

    Array(marc['264']).filter_map { |subfield| subfield.value.delete_suffix(',') if subfield.code == 'b' }.join(' ')
  end

  def url
    # https://www.loc.gov/marc/bibliographic/bd856.html
    field_856_for_resource = marc.fields.find { |field| field.tag == '856' && field.indicator2 == '0' }
    return unless field_856_for_resource

    field_856_for_resource.subfields.find { |subfield| subfield.code == 'u' }&.value
  end
end
