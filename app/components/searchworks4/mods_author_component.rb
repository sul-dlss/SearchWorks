# frozen_string_literal: true

module Searchworks4
    class ModsAuthorComponent < ViewComponent::Base
        def initialize(document:)
            @document = document
            super()
        end
        
        attr_reader :document

        def mods_authors
            authors = @document.mods.name&.map do |name| 
                mods_name_field(name) { |name| link_to(name, search_catalog_path(q: "\"#{name}\"", search_field: 'search_author')) }
            end 
            safe_join authors, '<br />'  
        end
    end
  end
  