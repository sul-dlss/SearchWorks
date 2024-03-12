# frozen_string_literal: true

class ProductionNotice < MarcField
  def values
    return {} if marc.blank?

    @values ||= extracted_fields.each_with_object({}) do |(field, subfields), hash|
      label = marc_264_labels[:"#{field.indicator1}#{field.indicator2}"]
      hash[label] ||= []
      hash[label] << display_value(field, subfields)
    end
  end

  def to_partial_path
    'marc_fields/production_notice'
  end

  private

  def tags
    %w[2643abc]
  end

  def marc_264_labels
    {
      " 0": "Production",
      "20": "Former production",
      "30": "Current production",
      " 1": "Publication",
      "21": "Former publication",
      "31": "Current publication",
      " 2": "Distribution",
      "22": "Former distribution",
      "32": "Current distribution",
      " 3": "Manufacture",
      "23": "Former manufacture",
      "33": "Current manufacture",
      " 4": "Copyright notice",
      "24": "Former copyright",
      "34": "Current copyright"
    }
  end
end
