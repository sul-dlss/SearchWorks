# frozen_string_literal: true

# Overriding the Blacklight component to bring the thumbnail up into the main section.
module Searchworks4
  class DocumentComponent < Blacklight::DocumentComponent
    attr_reader :document, :counter

    def resource_icon
      helpers.render_resource_icon(presenter.formats)
    end
  end
end
