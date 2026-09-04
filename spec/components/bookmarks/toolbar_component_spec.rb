# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Bookmarks::ToolbarComponent, type: :component do
  subject(:component) { described_class.new(document_ids:) }

  let(:document_ids) { [1, 2, 3] }

  describe '#bookmark_type' do
    it 'returns the correct selection type' do
      with_request_url '/selections/articles' do
        article_component = described_class.new(document_ids:)
        render_inline(article_component)
        expect(article_component.bookmark_type).to eq('article')
      end

      with_request_url '/selections' do
        catalog_component = described_class.new(document_ids:)
        render_inline(catalog_component)
        expect(catalog_component.bookmark_type).to eq('catalog')
      end
    end
  end

  it 'includes a button to remove all selections' do
    render_inline(component)

    expect(page).to have_button('Remove all')
    expect(page).to have_css('form[method="post"][action="/selections/clear?type=catalog"]')
    expect(page).to have_css('input[name="_method"][value="delete"]', visible: :hidden)
  end
end
