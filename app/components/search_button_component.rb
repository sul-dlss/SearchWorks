# frozen_string_literal: true

class SearchButtonComponent < Blacklight::SearchButtonComponent
  def call
    tag.button(class: 'btn btn-primary search-btn', type: 'submit', id: @id) do
      tag.span(@text, class: 'submit-search-text')
    end
  end
end
