# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module SearchResult
  class DocumentComponent < Blacklight::DocumentComponent
    def eds_restricted?
      SolrDocument::EDS_RESTRICTED_PATTERN.match?(@document['eds_title'])
    end

    def classes
      original = super
      original.push('eds-restricted') if eds_restricted?
      original
    end

    # NOTE: ideally this would override the metadata slot in Blacklight, but I'm not sure how to do that.
    def document_metadata
      return render ArticleComponent.new(document: @document) if controller_name == 'articles'

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
  end
end
