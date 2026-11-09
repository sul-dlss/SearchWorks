# frozen_string_literal: true

require Rails.root.join("app/models/solr_document")

module Record
  module Item
    module Marc
      # Previews the "Related items" browse nearby container on a record page,
      # filled with gallery cards that cover each SearchResult::DocumentGalleryComponent scenario.
      class CallnumberBrowseComponentPreview < Lookbook::Preview
        layout 'lookbook'

        # The record being viewed (two call numbers, so two tabs). Its card is the current document.
        RECORD_FIXTURE = "14205849.yml"

        # Gallery card scenarios, in shelf order around the current record. Only
        # records with a browse_nearby_struct can appear here, so there's no SDR-only
        # card: the indexer never gives those records a call number to browse by.
        GALLERY_FIXTURES = [
          "1391872.yml",       # Held in a single library
          "10838998.yml",      # Held in multiple libraries
          RECORD_FIXTURE,      # Current document, highlighted
          "in00000053236.yml", # Online-only resource (e-resource browse entry)
          "1.yml"              # No cover identifiers (ISBN, OCLC, LCCN), so always the placeholder
        ].freeze

        # Renders the gallery cards inline rather than lazily loading them from
        # the browse nearby endpoint, which needs Solr.
        class InlineFilmstripComponent < CallnumberBrowseComponent
          def initialize(gallery_documents:, **)
            super(**)
            @gallery_documents = gallery_documents
          end

          # Mirrors the markup app/views/browse/nearby.html.erb renders into the turbo frame
          def filmstrip(spine, preview_id:, **)
            helpers.turbo_frame_tag filmstrip_frame_id(spine), class: 'gallery' do
              tag.div class: 'd-flex' do
                presenters = @gallery_documents.map { |gallery_document| helpers.document_presenter(gallery_document) }

                render SearchResult::DocumentGalleryComponent.with_collection(presenters, starting_document: document, preview_id:)
              end
            end
          end
        end

        # The record (14205849) has two call numbers, so it shows two tabs; both
        # show the same cards. Cards, left to right: single library (1391872),
        # multiple libraries (10838998), the current record (14205849), online-only
        # (in00000053236), and no cover identifiers, which always renders the placeholder (1).
        #
        # @label Related items (browse nearby)
        def browse_nearby
          render InlineFilmstripComponent.new(
            document: SolrDocument.from_fixture(RECORD_FIXTURE),
            gallery_documents: GALLERY_FIXTURES.map { |fixture| SolrDocument.from_fixture(fixture) }
          )
        end
      end
    end
  end
end
