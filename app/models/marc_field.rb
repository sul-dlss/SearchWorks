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

  def remove_hidden_indicators
    relevant_fields.reject! do |field|
      (Constants::HIDE_1ST_IND.include?(field.tag) && field.indicator1 == '1') ||
        (Constants::HIDE_1ST_IND0.include?(field.tag) && field.indicator1 == '0')
    end
  end

  def remove_hidden_subfields
    relevant_fields.each do |field|
      field.subfields.reject! do |subfield|
        Constants::EXCLUDE_FIELDS.include?(subfield.code)
      end
    end
  end

  def merge_matched_vernacular_fields
    relevant_fields.each_with_index do |field, index|
      next if field.tag =~ /^880/
      next unless field_has_vernacular_matcher?(field)
      vernacular_field = matching_vernacular_field(field)
      relevant_fields.insert(index + 1, vernacular_field) if vernacular_field
    end
  end

  def append_unmatched_vernacular_fields
    marc.fields(['880']).each do |vernacular_field|
      next unless field_has_vernacular_matcher?(vernacular_field)
      tag, matcher = vernacular_field_tag(vernacular_field)
      next unless tags.include?(tag) && matcher == '00'
      relevant_fields.insert(tag_indexes[tag], vernacular_field)
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
    relevant_fields.group_by do |field|
      if field.tag == '880'
        vernacular_field_tag(field)[0]
      else
        field.tag
      end
    end
  end

  def run_preprocessors
    preprocessors.map(&method(:send))
  end

  def preprocessors
    [
      :remove_hidden_indicators,
      :merge_matched_vernacular_fields,
      :append_unmatched_vernacular_fields,
      :remove_hidden_subfields
    ]
  end

  def subfield_delimeter
    ' '
  end

  def i18n_key
    self.class.to_s.underscore
  end

  def matching_vernacular_field(field)
    tag_880, tag_matcher = vernacular_field_tag(field)
    marc.fields([tag_880]).find do |vernacular_field|
      next unless field_has_vernacular_matcher?(vernacular_field)
      venacular_original_tag, vernacular_matcher = vernacular_field_tag(vernacular_field)
      field.tag == venacular_original_tag && tag_matcher == vernacular_matcher
    end
  end

  def field_has_vernacular_matcher?(field)
    field['6'] && field['6'].include?('-')
  end

  def vernacular_field_tag(field)
    return [] unless field_has_vernacular_matcher?(field)
    field['6'][/^(\d{3})-(\d{2})/]
    [Regexp.last_match(1), Regexp.last_match(2)]
  end
end
