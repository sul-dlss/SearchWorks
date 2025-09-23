# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Searchworks4
  class DocumentComponent < Blacklight::DocumentComponent
    renders_one :flag

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end

    def default_flag
      Searchworks4::DocumentFlagComponent.new(document:)
    end
  end
end
