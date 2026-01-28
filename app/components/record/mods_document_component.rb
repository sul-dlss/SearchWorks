# frozen_string_literal: true

module Record
  class ModsDocumentComponent < Blacklight::DocumentComponent
    delegate :mods_record_field, :mods_name_field, :linked_mods_subjects, :linked_mods_genres, to: :helpers

    attr_reader :layout

    def initialize(document: nil, layout: Record::DocumentLayoutComponent, **)
      super(document:, **)

      @layout = layout
    end

    def truncated_mods_record_field(field, component: ModsDisplay::FieldComponent)
      render component.new(field: field, value_transformer: transformer, value_html_attributes: { data: { controller: 'long-text', 'long-text-truncate-class': 'truncate-5' } })
    end

    # Returns a lambda with the value escaped
    # Both places where this field is called, we use the same data attributes
    def transformer
      ->(v) { tag.div v.nil? ? nil : CGI.unescapeHTML(v), data: { 'long-text-target' => 'text' } }
    end
  end
end
