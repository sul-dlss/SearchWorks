# frozen_string_literal: true

###
#  MarcField is the base class to provide common
#  behavior for other classes to inherit from
###
class MarcField
  include ActionView::Helpers::OutputSafetyHelper
  include ActionView::Helpers::SanitizeHelper

  attr_reader :document, :tags

  delegate :present?, to: :values

  def initialize(solr_document, tags = [])
    @document = solr_document
    @tags = Array(tags)
    @subfield_delimiter = subfield_delimiter
  end

  def inspect
    "#<#{self.class.name}:0x#{object_id} @document=#<SolrDocument:#{document.id}>>"
  end

  def label
    I18n.t(
      :"searchworks.marc_fields.#{i18n_key}.label",
      default: [
        (:"searchworks.marc_fields.#{tags.first}.label" if tags.present?),
        (:"searchworks.marc_fields.#{tags.first.scan(/\d{3}|\w+/).first}.label" if tags.present?),
        :"searchworks.marc_fields.default.label"
      ].compact
    )
  end

  def values
    return [] unless marc.present?

    @values ||= extracted_fields.filter_map do |field, subfields|
      display_value(field, subfields)
    end
  end

  def to_partial_path
    'marc_fields/marc_field'
  end

  private

  def marc
    return {} unless document.respond_to?(:to_marc)

    document.to_marc
  end

  def i18n_key
    self.class.to_s.underscore
  end

  def extracted_fields
    MarcExtractor.new(marc, tags).extract
  end

  def subfield_delimiter
    @subfield_delimiter ||= I18n.t(
      :"searchworks.marc_fields.#{i18n_key}.delimiter",
      default: [
        (:"searchworks.marc_fields.#{tags.first}.delimiter" if tags.present?),
        (:"searchworks.marc_fields.#{tags.first.scan(/\d{3}|\w+/).first}.delimiter" if tags.present?),
        :"searchworks.marc_fields.default.delimiter"
      ].compact
    )
  end

  def display_value(field, subfields)
    return unless subfields.present?

    safe_join subfields.map { |subfield| subfield_value(field, subfield) }.map { |v| sanitize_marc_value(v) }, subfield_delimiter
  end

  def subfield_value(_field, subfield)
    case subfield.code
    when '4'
      Constants::RELATOR_TERMS[subfield.value] || subfield.value
    else
      subfield.value
    end
  end

  def sanitize_marc_value(value)
    return value if value.html_safe?

    sanitize(value.gsub("<", '&lt;').gsub(">", '&gt;'))
  end
end
