# frozen_string_literal: true

module Searchworks4
  class ModsAuthorsComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    # The comma should not be part of the link for the author name
    def label_display(label)
      return '' if label.blank?

      ", #{format_label(label)}"
    end

    def format_label(label)
      # Remove suffix for : if present at the end of the string
      # Downcase to meet expected display
      formatted_label = helpers.sanitize_mods_name_label(label).downcase
      # Remove any beginning and ending parentheses from post text
      formatted_label.gsub(/[()]/, '')
    end

    def mods_display_name
      @document.mods_display_name&.first
    end

    def mods_name
      @document.mods.name&.first
    end
  end
end
