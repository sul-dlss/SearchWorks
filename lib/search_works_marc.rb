require 'marc'

class SearchWorksMarc
  attr_reader :marc_record
  def initialize(marc_record)
    @marc_record = remove_fields marc_record.fields
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

  private
  def remove_fields fields
    remove_control_fields remove_custom_fields fields
  end

  def remove_control_fields fields
    fields.map { |field| field.tag =~ /00./ ? nil : field }.compact
  end

  def remove_custom_fields fields
    fields.map do |field|
      unless (Constants::HIDE_1ST_IND.include?(field.tag) and field.indicator1 == "1") or (Constants::HIDE_1ST_IND0.include?(field.tag) and field.indicator1 == "0")
        field
      end
    end.compact
  end

  def grouping
    @marc_record.group_by(&:tag)
  end

  def label_by_indicator key
    key
  end

  def format_subfields fields
    fields.map { |f| f.map { |sf| sf.value } }
  end

  def reject_excluded_subfields field
    unless Constants::EXCLUDE_FIELDS.include?(field.code)
      field
    end
  end
end
