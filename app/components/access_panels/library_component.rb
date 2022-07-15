module AccessPanels
  class LibraryComponent < ViewComponent::Base
    with_collection_parameter :library

    attr_reader :library, :document

    def initialize(library:, document:)
      @library = library
      @document = document
    end

    def thumb_for_library
      image_name = if library.zombie?
        "#{library.code}.png"
      else
        "#{library.code}.jpg"
      end
      image_tag(image_name, class: "pull-left", alt: "", height: 50)
    rescue Sprockets::Rails::Helper::AssetNotFound => e
      Honeybadger.notify(e, error_message: "Missing library thumbnail for #{library.code}")

      nil
    end

    def link_to_library_about_page(&block)
      link_to_if Constants::LIBRARY_ABOUT[library.code], capture(&block), Constants::LIBRARY_ABOUT[library.code]
    end
  end
end
