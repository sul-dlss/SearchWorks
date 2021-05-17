# frozen_string_literal: true

class Subjects < MarcField
  def values
    @values ||= begin
      data = []
      extracted_fields.each do |_field, subfields|
        multi_a = []
        temp_data_array = []
        temp_subs_text = []
        temp_xyv_array = []

        subfields.each do |sf|
          exclude = Constants::EXCLUDE_FIELDS.dup + ["1", "2", "3", "4", "7", "9"]
          next if exclude.include?(sf.code)

          if sf.code == "a"
            multi_a << sf.value unless sf.value[0, 1] == "%"
          elsif ["v", "x", "y", "z"].include?(sf.code)
            temp_xyv_array << sf.value
          else
            temp_subs_text << sf.value
          end
        end

        if multi_a.length > 1
          multi_a.each do |a|
            data << [a]
          end
        elsif multi_a.length == 1
          temp_data_array << [multi_a.first, temp_subs_text].flatten.compact.join(' ') unless temp_subs_text.blank? and multi_a.empty?
        elsif temp_subs_text.present?
          temp_data_array << temp_subs_text.join(' ')
        end

        temp_data_array.concat(temp_xyv_array) unless temp_xyv_array.empty?
        data << temp_data_array unless temp_data_array.empty?
      end

      data.uniq
    end
  end

  def to_partial_path
    'marc_fields/subjects'
  end
end
