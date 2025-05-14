# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult::MiniBento::LayoutComponent, type: :component do
  before do
    render_inline(described_class.new(close: true, url: '/foo?bar=baz', i18n_key: :catalog))
  end

  it 'draws the page' do
    expect(page).to have_css 'button.close'
    expect(page).to have_css '.alternate-catalog-title'
    expect(page).to have_css '.alternate-catalog-body'
    expect(page).to have_css 'ul.alternate-catalog-facets'
  end
end
