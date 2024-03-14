# frozen_string_literal: true

class MarcExtractor
  attr_reader :marc, :tags, :subfields

  def initialize(marc, tags)
    @marc = marc
    @tags = []
    @subfields = {}
    tags = tags.split(':') if tags.is_a? String

    Array.wrap(tags).each do |tag|
      t, subfields_spec = tag.to_s.scan(/\d{3}|\w+/)
      @tags << t
      @subfields[t] = subfields_spec&.chars
    end
  end

  def extract
    return to_enum(:extract) unless block_given?

    merged_and_matched_fields.each do |field|
      subfields = relevant_subfields(field).to_a
      yield field, subfields if subfields.present?
    end
  end

  private

  def merged_and_matched_fields
    return to_enum(:merged_and_matched_fields) unless block_given?

    relevant_fields.each do |field|
      next if hidden_by_indicator?(field)

      yield field

      vern = matching_vernacular_field(field) if !field.tag.start_with?('8') && field.vernacular_matcher?
      yield MarcFieldWrapper.new(vern) if vern
    end
  end

  # Return the MARC fields that match the requested tags or are unmatched vernacular fields for those tags
  # in the order they appear in the MARC record.
  def relevant_fields
    @relevant_fields ||= marc.fields(tags + ['880']).map { |field| MarcFieldWrapper.new(field) }.select do |field|
      field.tag != '880' || (
        field.vernacular_matcher? &&
        tags.include?(field.vernacular_matcher_tag) &&
        field.vernacular_matcher_iterator == '00'
      )
    end
  end

  def relevant_subfields(field)
    return to_enum(:relevant_subfields, field) unless block_given?

    field.subfields.each do |subfield|
      next unless include_subfield? field, subfield
      next if Constants::EXCLUDE_FIELDS.include?(subfield.code)

      case subfield.code
      when '4'
        next if field.tag.start_with?('8')

        yield MARC::Subfield.new(subfield.code, Constants::RELATOR_TERMS[subfield.value] || subfield.value)
      when 'a'
        yield subfield unless subfield.value.starts_with?('%')
      else
        yield subfield
      end
    end
  end

  def include_subfield?(field, subfield)
    return true unless subfields[field.canonical_tag]

    subfields[field.canonical_tag].include? subfield.code
  end

  def hidden_by_indicator?(field)
    (Constants::HIDE_1ST_IND.include?(field.canonical_tag) && field.indicator1 == '1') ||
      (Constants::HIDE_1ST_IND0.include?(field.canonical_tag) && field.indicator1 == '0')
  end

  def matching_vernacular_field(field)
    @field_cache ||= {}
    @field_cache[field.vernacular_matcher_tag] ||= marc.fields([field.vernacular_matcher_tag])

    @field_cache[field.vernacular_matcher_tag].find do |vern_field|
      vernacular_field = MarcFieldWrapper.new(vern_field)
      next unless vernacular_field.vernacular_matcher?

      field.tag == vernacular_field.vernacular_matcher_tag &&
        field.vernacular_matcher_iterator == vernacular_field.vernacular_matcher_iterator
    end
  end
end
