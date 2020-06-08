##
# A class to parse MARC 382 Medium of Performance for display
# https://www.loc.gov/marc/authority/ad382.html
class Instrumentation < MarcField
  def values
    relevant_values.group_by { |value| value[:label] }
  end

  def to_partial_path
    'marc_fields/instrumentation'
  end

  private

  def preprocessors
    super + [:relevant_subfields]
  end

  def relevant_subfields
    relevant_fields.each do |field|
      field.subfields = field.subfields.reject do |subfield|
        !%w(a b d n p s v).include?(subfield.code)
      end
    end
  end

  def terminating_subfield?(subfield)
    %w(a b).include?(subfield.code)
  end

  def relevant_values
    relevant_fields.map do |field|
      {
        label: field_label(field),
        value: process_field(field)
      }
    end
  end

  def process_field(field)
    array = []
    field.subfields.map do |subfield|
      value = subfield_value(subfield)
      if terminating_subfield?(subfield)
        array << value
      else
        last = array.pop
        array << [last, value].join(' ')
      end
    end
    array.join(', ')
  end

  def subfield_value(subfield)
    send("#{subfield.code}_subfield", subfield.value)
  end

  def a_subfield(value)
    value
  end

  def b_subfield(value)
    "solo #{value}"
  end

  def d_subfield(value)
    "/ #{value}"
  end

  def n_subfield(value)
    "(#{value})"
  end

  def p_subfield(value)
    "or #{value}"
  end

  def s_subfield(value)
    "(total=#{value})"
  end

  def v_subfield(value)
    "(#{value})"
  end

  def field_label(field)
    case field.indicator1.to_s
    when '0'
      'Instrumentation'
    when '1'
      'Partial instrumentation'
    end
  end

  def tags
    %w(382)
  end
end
