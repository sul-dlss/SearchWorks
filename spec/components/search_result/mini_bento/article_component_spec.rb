# frozen_string_literal: true

require "rails_helper"

RSpec.describe SearchResult::MiniBento::ArticleComponent, type: :component do
  before do
    vc_test_controller.params[:q] = 'question'
    render_inline(described_class.new(close: true))
  end

  it 'draws the page' do
    expect(page).to have_css '[data-alternate-catalog="/catalog?q=question"]'
    expect(page).to have_css 'button.btn-close'
    expect(page).to have_css '.alternate-catalog-title'
    expect(page).to have_css '.alternate-catalog-body'
    expect(page).to have_css 'a[href="/catalog?q=question"].btn'
    expect(page).to have_css 'ul.alternate-catalog-facets'
  end
end
