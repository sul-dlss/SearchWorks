class Instrumentation < SearchWorksMarc
  def initialize(marc_record)
    @marc_record = remove_fields marc_record
                    .fields
                    .select { |f| f.tag == '382' }
  end

  private
  def format_subfields fields
    fields.map do |section|
      temp_array = []
      j = 0
      section.each_with_index.map do |field, i|
        if field.code == 'n'
          append_to_previous code_to_string(field.code, field.value), temp_array, i - 1 - j
          j += 1
        else
          temp_array.push code_to_string field.code, field.value
        end
      end
      temp_array.compact
    end
  end
  
  def grouping
    @marc_record.group_by { |f| f.indicator1 }
  end

  def append_to_previous field, array, index
    array[index] = "#{array[index]} #{field}"
  end

  def label_by_indicator indicator
    self.send("indicator_#{indicator}")
  end

  def code_to_string code, value
    self.send("#{code}_subfield", value)
  end

  def indicator_0
    'Instrumentation'
  end

  def indicator_1
    'Partial instrumentation'
  end
  def a_subfield value
    value
  end

  def b_subfield value
    "solo #{value}"
  end

  def d_subfield value
    "doubling #{value}"
  end

  def n_subfield value
    "(#{value})"
  end

  def method_missing(method_name, *args, &block)
    case method_name
    when /._subfield$/
      nil
    when /^indicator_./
      nil
    else
      super
    end
  end
end
