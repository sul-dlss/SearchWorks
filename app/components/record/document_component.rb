# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Record
  class DocumentComponent < Blacklight::DocumentComponent
    # NOTE: ideally this would override the metadata slot in Blacklight, but I'm not sure how to do that.
    def document_metadata
      case @document.display_type
      when 'marc'
        render Item::Marc::MetadataComponent.new(document: @document)
      when 'mods'
        render Item::Mods::MetadataComponent.new(document: @document)
      when 'marc_collection'
        render Collection::Marc::MetadataComponent.new(document: @document)
      when 'mods_collection'
        render Collection::Mods::MetadataComponent.new(document: @document)
      else
        raise "Unknown display type #{@document.display_type}"
      end
    end

    def schema_dot_org
      render 'catalog/schema_dot_org_default', document: @document
    end
  end
end
