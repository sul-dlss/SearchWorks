# frozen_string_literal: true

module SearchworksMcp
  # Plain-text renderings shared by the catalog and article tools.
  module TextFormat
    module_function

    # First non-blank value among the given document fields, in order of preference.
    def first_value(document, field_names)
      field_names.each do |field_name|
        value = document[field_name]
        return value.first if value.is_a?(Array) && value.any?
        return value if value.is_a?(String) && value.present?
      end
      nil
    end

    # A single record: title, URL, then one "Label: value" line per metadata field.
    def record(result)
      lines = [result[:title], "URL: #{result[:url]}"]
      result[:metadata].each do |label, value|
        lines << "#{label.to_s.humanize}: #{Array(value).join('; ')}"
      end
      lines.join("\n")
    end

    def facets(facets)
      return "" if facets.empty?

      "\n\nAvailable refinement options:#{facet_list(facets)}"
    end

    def facet_list(facets)
      facets.map do |_key, facet|
        values = facet[:values].map { |value| "#{value[:value]} (#{value[:count]})" }.join(", ")
        "\n- #{facet[:label]}: #{values}"
      end.join
    end
  end
end
