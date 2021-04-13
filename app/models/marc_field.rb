###
#  MarcField is the base class to provide common
#  behavior for other classes to inherit from
###
class MarcField
  attr_reader :document, :tags, :subfield_delimeter

  delegate :present?, to: :values

  def initialize(solr_document, tags = [], subfield_delimeter: ' ')
    @document = solr_document
    @tags = tags
    @subfield_delimeter = subfield_delimeter
  end

  def inspect
    "#<#{self.class.name}:0x#{object_id} @document=#<SolrDocument:#{document.id}>>"
  end

  def label
    I18n.t(
      :"searchworks.marc_fields.#{i18n_key}.label",
      default: [
        (:"searchworks.marc_fields.#{tags.first}.label" if tags.present?),
        :"searchworks.marc_fields.default.label"
      ].compact
    )
  end

  def values
    return [] unless marc.present?

    extracted_fields.map do |field, subfields|
      subfields.map(&:value).join(subfield_delimeter)
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
end
