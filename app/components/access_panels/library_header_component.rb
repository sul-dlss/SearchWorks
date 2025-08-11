# frozen_string_literal: true

module AccessPanels
  class LibraryHeaderComponent < ViewComponent::Base
    attr_reader :library, :document

    def initialize(library:, document:)
      @library = library
      @document = document
      super()
    end

    # we don't need to fetch hours for SAL since it doesn't have hours
    def fetch_hours?
      library.code.exclude?('SAL')
    end

    def link_to_library_about_page(**)
      return library.name if library.about_url.blank?

      link_to library.about_url, ** do
        safe_join([
          library.name,
          tag.i(class: 'bi bi-arrow-up-right', aria: { hidden: true })
        ])
      end
    end
  end
end
