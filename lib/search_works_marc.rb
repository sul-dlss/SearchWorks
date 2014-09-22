require 'marc'

class SearchWorksMarc
  include Enumerable
  attr_reader :fields
  def initialize(marc_record)
    @marc_record = marc_record
    @fields = marc_record.fields.clone
    process_fields
  end

  def parse_marc_record
    label_array = []
    if defined?(grouping)
      grouping.each do |key, value|
        temp_hash = OpenStruct.new label: label_by_indicator(key)
        fields = value
                  .map { |f| f
                    .map { |sf| reject_excluded_subfields sf
                    }.compact
                  }
        temp_hash.values = format_subfields fields
        label_array.push temp_hash
      end
    end
    label_array
  end

  def present?
    @fields.present?
  end

  def each
    for record in parse_marc_record
      yield record
    end
  end

  private

  def process_fields
    remove_fields
    selected_fields
    match_vernacular
  end

  def selected_fields
    @fields
  end

  def match_vernacular
    @fields.each_with_index do |field, index|
      if (vernacular = vernacular_field(field)).present?
        @fields.insert(index+1, vernacular)
      end
    end
  end

  def vernacular_field(field)
    if field.tag != '880' && field['6']
      field_original = field.tag
      match_original = field['6'].split("-")[1]
      @marc_record.find_all{|f| ('880') === f.tag}.find do |field|
        if field['6'] and field['6'].include?("-")
          vern_code = field['6'][/^\d{3}-\d{2}/]
          field_880 = vern_code.split('-')[0]
          match_880 = vern_code.split('-')[1]
          if match_original == match_880 and field_original == field_880
            true
          end
        end
      end
    end
  end

  def remove_fields
    remove_control_fields
    remove_custom_fields
  end

  def remove_control_fields
    @fields.select! { |field| !(field.tag =~ /00./) }
  end

  def remove_custom_fields
    @fields.reject! do |field|
      (Constants::HIDE_1ST_IND.include?(field.tag) &&  field.indicator1 == "1") ||
      (Constants::HIDE_1ST_IND0.include?(field.tag) && field.indicator1 == "0")
    end
  end

  def grouping
    @fields.group_by(&:tag)
  end

  def label_by_indicator key
    key
  end

  def format_subfields fields
    fields.map { |f| f.map { |sf| sf.value }.join(' ') }
  end

  def reject_excluded_subfields field
    unless Constants::EXCLUDE_FIELDS.include?(field.code)
      field
    end
  end
end
