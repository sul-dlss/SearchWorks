# frozen_string_literal: true

module Articles
  class ArticleComponent < Blacklight::Component
    def initialize(presenter:)
      @presenter = presenter
      @document = presenter.document
      super()
    end

    def render?
      !@document.eds_restricted?
    end

    def sections
      helpers.blacklight_config.show.sections
    end

    def metadata_sections
      sections.keys.index_with do |section_name|
        collection = Blacklight::MetadataFieldComponent.with_collection(metadata_fields_for_section(section_name), layout: MetadataFieldLayoutComponent)

        collection if collection.any?(&:render?)
      end.compact
    end

    delegate :html_present?, to: :helpers

    attr_reader :document

    def metadata_fields_for_section(section_name)
      fields_to_render = sections[section_name]
      @presenter.field_presenters.select do |presenter|
        fields_to_render.keys.map(&:to_s).include? presenter.field_config.key.to_s
      end
    end
  end
end
