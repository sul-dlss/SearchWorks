###
#  MarcField is the base class to provide common
#  behavior for other classes to inherit from
###
class MarcField
  attr_reader :document, :tags
  delegate :present?, to: :relevant_fields

  def initialize(solr_document, tags = [])
    @document = solr_document
    @tags = tags
    run_preprocessors
  end

  def inspect
    "#<#{self.class.name}:0x#{object_id} @document=#<SolrDocument:#{document.id}>>"
  end

  def label
    I18n.t(
      "searchworks.marc_fields.#{i18n_key}.label",
      default: :"searchworks.marc_fields.default.label"
    )
  end

  def values
    relevant_fields.map do |field|
      field.subfields.map(&:value).join(subfield_delimeter)
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

  def relevant_fields
    return [] unless marc.present?

    @relevant_fields ||= marc.fields(tags)
  end

  def wrap_marc_fields
    relevant_fields.map! do |field|
      MarcFieldWrapper.new(field)
    end
  end

  def remove_hidden_indicators
    relevant_fields.reject! do |field|
      (Constants::HIDE_1ST_IND.include?(field.tag) && field.indicator1 == '1') ||
        (Constants::HIDE_1ST_IND0.include?(field.tag) && field.indicator1 == '0')
    end
  end

  def remove_hidden_subfields
    relevant_fields.each do |field|
      field.subfields = field.subfields.reject do |subfield|
        Constants::EXCLUDE_FIELDS.include?(subfield.code)
      end
    end
  end

  def translate_relator_terms
    relevant_fields.map do |field|
      field.subfields = field.subfields.map do |subfield|
        if subfield.code == '4'
          subfield.tap { |s| s.value = Constants::RELATOR_TERMS[s.value] || s.value }
        else
          subfield
        end
      end
    end
  end

  def merge_matched_vernacular_fields
    arr = []
    relevant_fields.each_with_index do |field, index|
      arr << field
      next if field.tag =~ /^880/
      next unless field.vernacular_matcher?

      vernacular_field = matching_vernacular_field(field)
      arr << MarcFieldWrapper.new(vernacular_field) if vernacular_field
    end

    relevant_fields.replace(arr)
  end

  def append_unmatched_vernacular_fields
    return unless marc.respond_to? :fields

    marc.fields(['880']).each do |vern_field|
      vernacular_field = MarcFieldWrapper.new(vern_field)
      next unless vernacular_field.vernacular_matcher? &&
                  tags.include?(vernacular_field.vernacular_matcher_tag) &&
                  vernacular_field.vernacular_matcher_iterator == '00'

      @relevant_fields.insert(tag_indexes[vernacular_field.vernacular_matcher_tag], vernacular_field)
    end
  end

  # Returns a hash where the keys are relevant tags
  # and the value is the index of the fields within
  # that particular tag. This is used so we can know
  # what the index of particular tag's fields are in
  # the relevant_fields array in order to inject
  # unmatched vernacular fields in the correct place
  def tag_indexes
    fields_index = 0
    tags.each_with_object({}) do |tag, hash|
      fields_index += grouped_fields[tag].length if grouped_fields[tag].present?
      hash[tag] = fields_index
    end
  end

  def grouped_fields
    relevant_fields.group_by(&:canonical_tag)
  end

  def run_preprocessors
    preprocessors.map(&method(:send))
  end

  def preprocessors
    [
      :wrap_marc_fields,
      :remove_hidden_indicators,
      :merge_matched_vernacular_fields,
      :append_unmatched_vernacular_fields,
      :remove_hidden_subfields,
      :translate_relator_terms
    ]
  end

  def subfield_delimeter
    ' '
  end

  def i18n_key
    self.class.to_s.underscore
  end

  def matching_vernacular_field(field)
    marc.fields([field.vernacular_matcher_tag]).find do |vern_field|
      vernacular_field = MarcFieldWrapper.new(vern_field)
      next unless vernacular_field.vernacular_matcher?

      field.tag == vernacular_field.vernacular_matcher_tag &&
        field.vernacular_matcher_iterator == vernacular_field.vernacular_matcher_iterator
    end
  end
end
