# Mixin to provide a display_type string for determining which
# partial for Blacklight to render. This handles translating
# the formats and whitelisting supported format types.

module DisplayType

  def display_type
    return nil unless self[:display_type].present?
    @display_type ||= Processor.new(self).to_s
  end
  private
  class Processor
    delegate :is_a_collection?, to: :document
    def initialize(solr_document)
      @document = solr_document
      @display_types = solr_document[:display_type]
    end
    def to_s
      generate_display_type_string
    end

    private
    def document
      @document
    end
    def generate_display_type_string
      types = process_display_types_by_count.dup
      types.prepend('merged_') if has_merge_behavior?
      types.concat('_collection') if is_a_collection?
      types
    end
    def process_display_types_by_count
      case translated_display_types.length
      when 0 then 'marc'
      when 1 then translated_display_types.first
      else "complex"
      end
    end
    def includes_marc?
      @display_types.include?('sirsi')
    end
    def has_merge_behavior?
      @display_types.length > 1 && includes_marc?
    end
    def translated_display_types
      types = @display_types.dup
      types.delete('sirsi')
      types.sort.map do |type|
        translated_type = (display_type_translations[type] || type)
        if supported_display_types.include?(translated_type)
          translated_type
        else
          fallback_display_type
        end
      end
    end
    # This currently allows us to map production
    # display type values to what we'll eventually want.
    # We will need to remove everything but sirsi.
    def display_type_translations
      {"sirsi"             => "marc",
       "hydrus_object"     => "file",
       "hydrus_collection" => "file",
       "collection"        => "image"
     }
    end
    def supported_display_types
      ["image", "file", "sirsi", "hydrus_object", "hydrus_collection"]
    end
    def fallback_display_type
      "file"
    end
  end
end
