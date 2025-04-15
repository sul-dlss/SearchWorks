# frozen_string_literal: true

module Record
  class ModsBibliographicComponent < ViewComponent::Base
    def initialize(document:)
      super
      @document = document
    end

    attr_reader :document

    # If the document has a druid, we don't want to show the purl for the object on the page twice.
    # The purl will show up in the OtherListingsComponent if there is a druid
    # this removes any locations that match https://purl.stanford.edu/druid
    def locations
      document.mods.location.reject { |location| location.values.detect { |loc| document.druid && /#{Settings.PURL_EMBED_RESOURCE}#{document.druid}/.match?(loc) } }
    end
  end
end
