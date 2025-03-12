# frozen_string_literal: true

module AccessPanels
  class LibraryComponent < ViewComponent::Base
    with_collection_parameter :library

    attr_reader :library, :document

    # @params [Holdings::Library] library the holdings for the item at a particular library
    # @params [SolrDocument] document
    def initialize(library:, document:)
      @library = library
      @document = document
    end

    def thumb_for_library
      image_name = if library.zombie?
        "ZOMBIE.png"
      else
        "#{library.code}.jpg"
      end
      image_tag(image_name, class: "pull-left", alt: "", height: 50)
    rescue Sprockets::Rails::Helper::AssetNotFound => e
      Honeybadger.notify(e, error_message: "Missing library thumbnail for #{library.code}")

      nil
    end

    def link_to_library_about_page(&)
      link_to_if library.about_url, capture(&), library.about_url
    end
  end
end
